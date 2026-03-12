load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@diff.bzl//diff:defs.bzl", "diff_multiple")
load(":diff_files.bzl", "diff_files")

write_file(
    name = "file1",
    out = "file1.gen",
    content = [
        "file1_content",
        "",
    ],
)

write_file(
    name = "file2",
    out = "file2.gen",
    content = [
        "file2_content",
        "",
    ],
)

diff_files(
    name = "diff_files",
    srcs = [
        ":file1",
        ":file2",
    ],
)

diff_multiple(
    name = "diff",
    srcs = [
        "file1.txt",
        "file2.txt",
    ],
    validate = 1,
    deps = [":diff_files"],
)
