"""Macro for syncing files and directories to the source tree"""

load("@bazel_lib//lib:utils.bzl", "is_external_label", "to_label")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:fail_analysis_test.bzl", "fail_analysis_test")
load("//diff/private:utils.bzl", "source_file_info")
load("//diff/private:write_source_file.bzl", _write_source_file = "write_source_file")
load(":cmp.bzl", "cmp")

def sync_source_bin(name, origin, out):
    """Synchronize a vendored source tree binary with another binary.

    Compares the binaries using `cmp` with validation enabled, and creates an executable "sync" target to update the `out` binary in the source tree.

    If the `out` binary does not exist, or if it differs from `origin`,
    then a failure message will appear describing the executable target to run
    to materialize it in the source tree.

    Failures occur early—in the analysis phase if the binary does not exist,
    or at build time as a failed validation action—rather than at test time.

    Args:
        name: Name of the executable target to update the `out` binary in the source tree
        origin: Label to the binary containing the desired state (what `out` should match)
        out: Label to the source tree binary to synchronize.
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
Error: sync_source_bin declares an `out` file that is not in the same package as the target.

{} is not in the package @{}//{}
""".format(out, native.repo_name(), native.package_name()))

    out_file_path = "{}/{}".format(out_label.package, out_label.name)
    (exists, _) = source_file_info(out_label)
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
    else:
        cmp(
            name = "{}_cmp".format(name),
            srcs = [out, origin],
            out = "{}.out".format(name),
            validate = 1,
            validation_error_msg = """\
Source binary {} is out of sync with its origin.

To update, run:

bazel run //{}:{} --norun_validations
""".format(out_file_path, native.package_name(), name),
        )

    _write_source_file(
        name = name,
        src = origin,
        dst = "{}/{}".format(native.package_name(), Label(out).name),
    )
