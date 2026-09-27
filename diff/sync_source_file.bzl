load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:patch_source_file.bzl", _patch_source_file = "patch_source_file")
load("//diff/private:write_source_file.bzl", _write_source_file = "write_source_file")
load("//diff/private:fail_analysis_test.bzl", "fail_analysis_test")
load(":defs.bzl", "cmp", "diff")

def _source_file_info(file):
    label = Label(file)
    all = native.glob([label.name], allow_empty = True, exclude_directories = 0)
    files_only  = native.glob([label.name], allow_empty = True)

    exists = len(all) > 0
    is_directory = exists and not files_only 

    return (exists, is_directory)

def sync_source_file(name, in_file, out_file, binary = False, mode = "patch"):
    # Allow the in_file to be generated easily for tests using partials.
    # The out_file # by definition must be a source file and cannot be generated.
    if partial.is_instance(in_file):
        target = name + ".1"
        partial.call(in_file, name = target, out = target + ".in")
        in_file = target

    (exists, is_directory) = _source_file_info(out_file)
    if not exists:
        fail_analysis_test(
            name = "{}_exists_test".format(name),
            message = """\
Error: does not exist",

bazel run //{}:{} --norun_validations
""".format(native.package_name(), "{}_create".format(name))
        )

        _write_source_file(
            name = "{}_create".format(name),
            src = in_file,
            dst = "{}/{}".format(native.package_name(), Label(out_file).name)
        )

        return

    if binary:
        if is_directory:
            fail("directory is not a binary")

        if mode == "patch":
            print("Warning: sync_source_file mode = \"patch\" is incompatible with binary files; implicitly using mode = \"write\". Set the correct \"mode\" to remove this warning.")

        # TODO: do a similar flow but with cmp
        cmp(
            name = "{}_cmp".format(name),
            srcs = [out_file, in_file],
            out = "{}.out".format(name),
            validate = 1,
        )

        _write_source_file(
            name = name,
            src = in_file,
            dst = "{}/{}".format(native.package_name(), Label(out_file).name)
        )
    else:

            

        diff_args = ["--unified"]
        if is_directory:
            diff_args.append("--new-file")

        diff(
            name = "{}_patch".format(name),
            srcs = [out_file, in_file],
            patch = "{}.patch".format(name),
            args = diff_args,
            validate = 1,
            validation_error_msg = """\
File differs from source. To update, run:

    bazel run //{}:{} --norun_validations
""".format(native.package_name(), name)
        )

        if mode == "patch":
            _patch_source_file(
                name = name,
                patch = ":{}_patch".format(name),
            )
        else:
            _write_source_file(
                name = name,
                src = in_file,
                dst = "{}/{}".format(native.package_name(), Label(out_file).name)
            )
