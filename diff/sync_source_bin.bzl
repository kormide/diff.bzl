load("//diff/private:fail_analysis_test.bzl", "fail_analysis_test")
load("//diff/private:write_source_file.bzl", _write_source_file = "write_source_file")
load(":defs.bzl", "cmp")

def _source_file_info(file):
    label = Label(file)
    all = native.glob([label.name], allow_empty = True, exclude_directories = 0)
    files_only = native.glob([label.name], allow_empty = True)

    exists = len(all) > 0
    is_directory = exists and not files_only

    return (exists, is_directory)

def sync_source_bin(name, in_file, out_file, binary = False, mode = "patch"):
    (exists, _) = _source_file_info(out_file)
    if not exists:
        fail_analysis_test(
            name = "{}_exists_test".format(name),
            message = """\
Error: does not exist",

bazel run //{}:{} --norun_validations
""".format(native.package_name(), "{}_create".format(name)),
        )

        _write_source_file(
            name = "{}_create".format(name),
            src = in_file,
            dst = "{}/{}".format(native.package_name(), Label(out_file).name),
        )

        return

        print("Warning: sync_source_file mode = \"patch\" is incompatible with binary files; implicitly using mode = \"write\". Set the correct \"mode\" to remove this warning.")

    cmp(
        name = "{}_cmp".format(name),
        srcs = [out_file, in_file],
        out = "{}.out".format(name),
        validate = 1,
    )

    _write_source_file(
        name = name,
        src = in_file,
        dst = "{}/{}".format(native.package_name(), Label(out_file).name),
    )
