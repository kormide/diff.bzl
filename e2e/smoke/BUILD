"""Provides a simple way to test your rules as an external workspace.
Add a basic smoke-test target below.
"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@diff.bzl", "diff")

diff(
    name = "case.1",
    exit_code = "case.1.exit_code",
    # Shorthand to write a generated file with some content we can run through awk.
    # Typically your content would come from a source file, or the output of some other rule.
    file1 = partial.make(
        write_file,
        content = ["hello"],
    ),
    file2 = partial.make(
        write_file,
        content = ["goodbye"],
    ),
)
