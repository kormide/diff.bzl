load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
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
)

diff(
    name = "case.3",
    args = [
        "--recursive",
        "--new-file",
    ],
    file1 = "case.3.dir_a",
    file2 = "case.3.dir_b",
)

diff(
    name = "case.3.assert_diff",
    file1 = "case.3.patch",
    file2 = partial.make(
        write_file,
        content = [
            "diff --recursive --new-file diff/tests/case.3.dir_a/cow.txt diff/tests/case.3.dir_b/cow.txt",
            "0a1",
            "> moo, moooooo!",
            "diff --recursive --new-file diff/tests/case.3.dir_a/file.txt diff/tests/case.3.dir_b/file.txt",
            "1a2",
            "> goodbye",
            "",
        ],
    ),
    validate = 1,
)

diff(
    name = "case.4",
    args = [
        "--recursive",
        "--unified",
    ],
    file1 = partial.make(
        copy_to_directory,  # Create an empty directory
    ),
    file2 = partial.make(
        copy_to_directory,  # Create an empty directory
    ),
    validate = 1,
)

genrule(
    name = "case.5",
    srcs = [],
    outs = ["case.5.txt"],
    cmd = "$(DIFF_BIN) --help > $@",
    toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
)

build_test(
    name = "build_test",
    targets = [
        ":case.3.assert_diff",
        ":case.4",
    ],
)
