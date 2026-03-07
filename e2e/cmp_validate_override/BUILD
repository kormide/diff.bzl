load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@diff.bzl", "cmp")

cmp(
    name = "compare",
    file1 = "a",
    file2 = "b",
    validate = 0,
)

build_test(
    name = "build_test",
    targets = [
        ":compare",
    ],
)
