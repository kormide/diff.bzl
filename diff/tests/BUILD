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
        "--unified",
        "--new-file",
    ],
    exit_code = "case.3.exit_code",
    file1 = "case.3.dir_a",
    file2 = "case.3.dir_b",
)

diff(
    name = "case.3.assert_exit_1",
    file1 = "case.3.exit_code",
    file2 = partial.make(
        write_file,
        content = [
            "1",
            "",
        ],
    ),
    validate = True,
)

diff(
    name = "case.3.assert_diff",
    file1 = "case.3.patch",
    file2 = partial.make(
        write_file,
        content = [
            "diff --recursive --unified --new-file diff/tests/case.3.dir_a/cow.txt diff/tests/case.3.dir_b/cow.txt",
            "--- diff/tests/case.3.dir_a/cow.txt	1969-12-31 16:00:00.000000000 -0800",
            "+++ diff/tests/case.3.dir_b/cow.txt	2026-01-23 16:40:30.908899317 -0800",
            "@@ -0,0 +1 @@",
            "+moo, moooooo!",
            "diff --recursive --unified --new-file diff/tests/case.3.dir_a/file.txt diff/tests/case.3.dir_b/file.txt",
            "--- diff/tests/case.3.dir_a/file.txt	2026-01-23 16:40:30.908899317 -0800",
            "+++ diff/tests/case.3.dir_b/file.txt	2026-01-23 16:40:30.909669226 -0800",
            "@@ -1 +1,2 @@",
            " hello",
            "+goodbye",
            "",
        ],
    ),
    validate = True,
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
    validate = True,
)

build_test(
    name = "build_test",
    targets = [
        ":case.3.assert_diff",
        ":case.3.assert_exit_1",
        ":case.4",
    ],
)
