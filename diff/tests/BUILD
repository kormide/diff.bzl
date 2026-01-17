load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//diff:defs.bzl", "diff")

diff(
    name = "case.2",
    args = ["--unified"],
    file1 = "some_file.txt",
    file2 = partial.make(
        write_file,
        content = [
            "file2",
            "",
        ],
    ),
    # Change to True to get a build failure
    validate = False,
)
