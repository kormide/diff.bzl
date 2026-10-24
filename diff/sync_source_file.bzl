"""Macro for syncing files and directories to the source tree"""

load("@bazel_lib//lib:utils.bzl", "is_external_label", "to_label")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("//diff/private:fail_analysis_test.bzl", "fail_analysis_test")
load("//diff/private:patch_source_file.bzl", _patch_source_file = "patch_source_file")
load("//diff/private:utils.bzl", "source_file_info")
load("//diff/private:write_source_file.bzl", _write_source_file = "write_source_file")
load(":diff.bzl", "diff")

def _fix_message(source_file_path, preview_target, update_target):
    msg = """\
Source file {} is out of sync with its origin.
{{}}
""".format(source_file_path)
    if preview_target:
        msg = msg.format("""\

To preview the differences, run:

bazel run {}
{{}}""".format(preview_target))

    msg = msg.format("""\

To update, run:

bazel run {} --norun_validations """.format(update_target))

    return msg

def sync_source_file(name, origin, out, mode = "patch", source_patch_output_groups = ["diff_bzl__patch"], preview_target = "@diff.bzl//diff:default_preview", preview_target_additional_args = [], validate = True):
    """Synchronize a source tree file or directory (`out`) with the contents with another file or directory (the `origin`).

    Generates a patch using `diff` from the `origin` file to the `out` file with
    validation enabled, and creates an executable "sync" target to update the `out`
    file in the source tree.

    If the `out` file does not exist, or if it differs from `origin`,
    then a failure message will appear describing the executable target to run
    to materialize or patch it in the source tree.

    Failures occur early—in the analysis phase if the file does not exist,
    or at build time as a failed validation action—rather than at test time.

    Synchronization is done by applying a patch to the `out` file
    (mode = "patch", the default), or by copying over it with `origin`'s contents
    (mode = "copy").

    Args:
        name: Name of the executable target to update the `out` file in the source tree
        origin: Label to the file or directory containing the desired state (what `out` should match)
        out: Label to the source tree file or directory to synchronize
        mode: The synchronization mode, "patch" (default) to apply a patch, or
            "copy" to copy over the `out` file
        source_patch_output_groups: Additional output groups to add the source file patch to
        preview_target: An executable target to run to preview the difference between the two
            files. The executable will be invoked with the two files as positional arguments.
            Defaults to a target that runs sdiff.
        preview_target_additional_args: Additional arguments to pass to the preview executable target
        validate: Whether to fail the build when the files differ. Setting this to `False` retains
            the executable preview and update targets but the difference will not be flagged in an
            error message.
    """

    # Allow the origin file to be generated easily for tests using partials.
    # The out file by definition must be a source file and cannot be generated.
    if partial.is_instance(origin):
        target = name + ".1"
        partial.call(origin, name = target, out = target + ".in")
        origin = target

    out_label = to_label(out)
    if is_external_label(out_label) or out_label.package != native.package_name():
        fail("""
Error: sync_source_file declares an `out` file that is not in the same package as the target.

{} is not in the package @{}//{}
""".format(out, native.repo_name(), native.package_name()))

    out_file_path = "{}/{}".format(out_label.package, out_label.name)
    (exists, is_directory) = source_file_info(out_label)
    if not exists:
        # Mint a test that will always fail during the analysis phase if the source tree
        # file does not exist. This is preferable to failing during the loading phase
        # so that we can mint the executable rule below to create the file, and instruct
        # how to do so in its error message.
        fail_analysis_test(
            name = "{}_exists_test".format(name),
            message = """\
{} does not exist in the source tree. To create it, run:

bazel run //{}:{} --norun_validations

""".format(out_file_path, native.package_name(), name),
        )

        _write_source_file(
            name = name,
            src = origin,
            dst = "{}/{}".format(native.package_name(), Label(out).name),
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
        srcs = [out, origin],
        patch = "{}.patch".format(name),
        args = diff_args,
        source_patch_output_groups = source_patch_output_groups,
        validate = validate,
        validation_error_msg = _fix_message(out_file_path, "//{}:{}.preview".format(native.package_name(), name) if preview_target else None, "//{}:{}".format(native.package_name(), name)),
    )

    if mode == "patch":
        _patch_source_file(
            name = name,
            patch = ":{}_patch".format(name),
        )
    elif mode == "copy":
        _write_source_file(
            name = name,
            src = origin,
            dst = "{}/{}".format(native.package_name(), out_label.name),
        )
    else:
        fail("Error: unknown mode \"{}\" passed to sync_source_file {}".format(mode))

    if preview_target:
        native_binary(
            name = "{}.preview".format(name),
            src = preview_target,
            data = [out, origin],
            args = ["$(rootpath {})".format(out), "$(rootpath {})".format(origin)] + preview_target_additional_args,
        )
