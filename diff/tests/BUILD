load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//diff:defs.bzl", "diff")

diff(
    name = "case.1",
    exit_code = "case.1.exit_code",
    file1 = partial.make(
        write_file,
        content = [
            "hello",
            "",
        ],
    ),
    file2 = partial.make(
        write_file,
        content = [
            "goodbye",
            "",
        ],
    ),
)
