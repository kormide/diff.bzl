"""TODO"""

load("@bazel_lib//lib:utils.bzl", "is_external_label", "to_label")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:fail_analysis_test.bzl", "fail_analysis_test")
load("//diff/private:utils.bzl", "label_to_safe_target_name", "source_files_info")
load("//diff/private:write_source_file.bzl", _write_source_file = "write_source_file")

def sync_source_files(name, files, mode = "patch", source_patch_output_groups = ["diff_bzl__patch"]):
    # Allow the origin files to be generated easily for tests using partials.
    # The out files by definition must be a source file and cannot be generated.
    for out, origin in files.items():
        if partial.is_instance(origin):
            target = "{}.{}.partial".format(name, label_to_safe_target_name(out))
            partial.call(origin, name = target, out = target + ".in")
            files[out] = target

    files = {to_label(out): origin for out, origin in files.items()}

    package_name = native.package_name()
    for out_label in files:
        if is_external_label(out_label) or out_label.package != package_name:
            fail("""
Error: sync_source_files declares a source file that is not in the same package as the target.

{} is not in the package @{}//{}
""".format(out, native.repo_name(), native.package_name()))

    (exists, is_directory) = source_files_info(files.keys())
    count = len(exists)

    out_files = files.keys()
    origins = files.values()
    missing_outs = [out_files[i] for i in range(count) if not exists[i]]
    missing_origins = [origins[i] for i in range(count) if not exists[i]]
    missing_out_file_paths = ["{}/{}".format(out_label.package, out_label.name) for out_label in missing_outs]

    if len(missing_out_file_paths) > 0:
        # Mint a test that will always fail during the analysis phase if any of the source
        # tree ("out") files do not exist. This is preferable to invoking fail() during the
        # loading phase so that we can mint the executable rule below to create the files,
        # and instruct
        # how to do so in its error message.
        fail_analysis_test(
            name = "{}_exists_test".format(name),
            message = """\
The following files do not exist in the source tree:

{}

To create them, run:

bazel run //{}:{} --norun_validations

""".format("\n".join(missing_out_file_paths), package_name, name),
        )

        _write_source_file(
            name = name,
            srcs = missing_origins,
            dsts = missing_out_file_paths,
        )

        return
