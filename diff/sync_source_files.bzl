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

    for out_label in files:
        if is_external_label(out_label) or out_label.package != native.package_name():
            fail("""
Error: sync_source_files declares an `out` file that is not in the same package as the target.

{} is not in the package @{}//{}
""".format(out, native.repo_name(), native.package_name()))

    (exists, is_directory) = source_files_info(files.keys())

    print(exists)
    print(is_directory)

    for i, out_label in enumerate(files.keys()):
        if not exists[i]:
            out_file_path = "{}/{}".format(out_label.package, out_label.name)

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
                src = files[out_label],
                dst = "{}/{}".format(native.package_name(), Label(out).name),
            )

            return
