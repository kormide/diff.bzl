load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@diff.bzl", "cmp", "diff")

cmp(
    name = "cmp",
    file1 = "a",
    file2 = "b",
    validate = 0,
)

diff(
    name = "diff",
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
    validate = 0,
)

build_test(
    name = "build_test",
    targets = [
        ":cmp",
        ":diff",
    ],
)
