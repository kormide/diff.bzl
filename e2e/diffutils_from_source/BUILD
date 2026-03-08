"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@diff.bzl", "diff")

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
    patch = "diff.patch",
)

build_test(
    name = "build_test",
    targets = [
        ":diff",
    ],
)
