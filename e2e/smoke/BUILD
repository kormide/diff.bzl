"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@diff.bzl", "diff")

diff(
    name = "patch",
    # Shorthand to write a generated file with some content we can run through diff.
    # Typically your content would come from a source file, or the output of some other rule.
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

diff(
    name = "validate",
    file1 = ":patch",
    file2 = partial.make(
        write_file,
        content = [
            "1c1",
            "< hello",
            "---",
            "> goodbye",
            "",
        ],
    ),
)

build_test(
    name = "smoke_test",
    targets = [
        ":patch",
        ":validate",
    ],
)
