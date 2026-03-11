load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory")
load("@bazel_skylib//lib:partial.bzl", "partial")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//diff:defs.bzl", "cmp", "diff")

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

cmp(
    name = "case.6.same_binary_file",
    file1 = "case.6.a",
    file2 = "case.6.b",
    validate = 1,
)

cmp(
    name = "case.7.different_binary_files",
    file1 = "case.7.a",
    file2 = "case.7.b",
)

diff(
    name = "case.7.output",
    file1 = "case.7.different_binary_files.out",
    file2 = partial.make(
        write_file,
        content = [
            "diff/tests/case.7.a diff/tests/case.7.b differ: char 1, line 1",
            "",
        ],
    ),
    validate = 1,
)

cmp(
    name = "case.8.verbose",
    args = ["--verbose"],
    file1 = "case.8.a",
    file2 = "case.8.b",
)

diff(
    name = "case.8.output",
    file1 = "case.8.verbose.out",
    file2 = partial.make(
        write_file,
        content = [
            "1 125  10",
            "2 142  77",
            "3  46 171",
            "4  41 312",
            "5  62 134",
            "6 315 353",
            "7 231 360",
            "8 231 167",
            "",
        ],
    ),
    validate = 1,
)

diff(
    name = "case.9.normal",
    args = ["--normal"],
    file1 = partial.make(
        write_file,
        content = [
            "moo",
            "",
        ],
    ),
    file2 = partial.make(
        write_file,
        content = [
            "cow",
            "",
        ],
    ),
)

diff(
    name = "case.9.diff",
    file1 = ":case.9.normal",
    file2 = partial.make(
        write_file,
        content = [
            "1c1",
            "< moo",
            "---",
            "> cow",
            "",
        ],
    ),
    validate = 1,
)

diff(
    name = "case.10.context_deterministic_label",
    args = ["--context"],
    file1 = partial.make(
        write_file,
        content = [
            "moo",
            "",
        ],
    ),
    file2 = partial.make(
        write_file,
        content = [
            "cow",
            "",
        ],
    ),
)

diff(
    name = "case.10.diff",
    file1 = ":case.10.context_deterministic_label",
    file2 = partial.make(
        write_file,
        content = [
            "*** diff/tests/case.10.context_deterministic_label.file1.in",
            "--- diff/tests/case.10.context_deterministic_label.file2.in",
            "***************",
            "*** 1 ****",
            "! moo",
            "--- 1 ----",
            "! cow",
            "",
        ],
    ),
    validate = 1,
)

build_test(
    name = "build_test",
    targets = [
        ":case.3.assert_diff",
        ":case.4",
    ],
)
