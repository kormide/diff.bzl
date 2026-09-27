"""Macro for syncing files and directories to the source tree."""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:fail_analysis_test.bzl", "fail_analysis_test")
load("//diff/private:patch_source_file.bzl", _patch_source_file = "patch_source_file")
load("//diff/private:write_source_file.bzl", _write_source_file = "write_source_file")
load(":defs.bzl", "diff")

def _source_file_info(file):
    """Determine whether a file exists in the source tree and is a directory

    Args:
        file: The file name or label

    Returns:
        A boolean pair tuple (exists, is_directory) indicating the file's existence
        and whether it's a directory

    """
    label = Label(file)
    all = native.glob([label.name], allow_empty = True, exclude_directories = 0)
    files_only = native.glob([label.name], allow_empty = True)

    exists = len(all) > 0
    is_directory = exists and not files_only

    return (exists, is_directory)

def sync_source_file(name, in_file, out_file, mode = "patch"):
    """Synchronize a source tree file or directory (the `out_file`) with the contents with another file or directory (the `in_file`).

    Generates a patch using `diff` from the `in_file` to the `out_file` and mints an executable
    target to update the `out_file` in the source tree.

    If the `out_file` does not exist, or if it differs from its counterpart,
    then a failure message will appear describing the executable target to run
    to materialize or patch it in the source tree.

    Failures occur early—in the analysis phase if the file does not exist,
    or at build time as a failed validation action—rather than at test time.

    Synchronization is done by applying a patch to the `out_file`
    (mode = "patch", the default), or by copying over it with `in_file` contents
    (mode = "copy").

    Args:
        name: Name of the executable target to update the `out_file` in the source tree
        in_file: Label to the file or directory containing the desired state (what `out_file` should match)
        out_file: Label to the source tree file or directory to synchronize.
        mode: The synchronization mode, "patch" (default) to apply a patch, or
            "copy" to copy over the `out_file`.
    """

    # Allow the in_file to be generated easily for tests using partials.
    # The out_file by definition must be a source file and cannot be generated.
    if partial.is_instance(in_file):
        target = name + ".1"
        partial.call(in_file, name = target, out = target + ".in")
        in_file = target

    (exists, is_directory) = _source_file_info(out_file)
    if not exists:
        out_file_path = "{}/{}".format(native.package_name(), out_file)

        # Mint a test that will always fail during the analysis phase if the source tree
        # file does not exist. This is preferable to failing during the loading phase
        # so that we can mint the executable rule below to create the file, and instruct
        # how to do so in its error message.
        fail_analysis_test(
            name = "{}_exists_test".format(name),
            message = """\
{} does not exist in the source tree. To create it, run:

bazel run //{}:{} --norun_validations

""".format(out_file_path, native.package_name(), "{}_create".format(name)),
        )

        _write_source_file(
            name = "{}_create".format(name),
            src = in_file,
            dst = "{}/{}".format(native.package_name(), Label(out_file).name),
        )

        return

    # Use the "unified" patch format because it is most likely to create
    # a patch that can be reliably applied back to the source tree.
    diff_args = ["--unified"]
    if is_directory:
        diff_args.append("--new-file")
        diff_args.append("--recursive")

    diff(
        name = "{}_patch".format(name),
        srcs = [out_file, in_file],
        patch = "{}.patch".format(name),
        args = diff_args,
        validate = 1,
        validation_error_msg = """\
File differs from source. To update, run:

bazel run //{}:{} --norun_validations
""".format(native.package_name(), name),
    )

    if mode == "patch":
        _patch_source_file(
            name = name,
            patch = ":{}_patch".format(name),
        )
    elif mode == "copy":
        _write_source_file(
            name = name,
            src = in_file,
            dst = "{}/{}".format(native.package_name(), Label(out_file).name),
        )
    else:
        fail("Error: unknown mode \"{}\" passed to sync_source_file".format(mode))
