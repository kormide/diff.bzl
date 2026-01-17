"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@diff.bzl", "diff")

diff(
    name = "case.1",
    out = "case.1.diff",
    exit_code = "case.1.exit_code",
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
    name = "case.1.assert_diff",
    file1 = "case.1.diff",
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

diff(
    name = "case.1.assert_exit_1",
    file1 = "case.1.exit_code",
    file2 = partial.make(
        write_file,
        content = [
            "1",
            "",
        ],
    ),
)

build_test(
    name = "smoke_test",
    targets = [
        ":case.1.assert_diff",
        ":case.1.assert_exit_1",
    ],
)
