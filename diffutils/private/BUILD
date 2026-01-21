load("@bazel_lib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "diff",
    srcs = [
        "diff.bzl",
        "options.bzl",
    ],
    visibility = ["//diffutils:__subpackages__"],
)

bzl_library(
    name = "toolchains_repo",
    srcs = ["toolchains_repo.bzl"],
    visibility = ["//diffutils:__subpackages__"],
)

bzl_library(
    name = "versions",
    srcs = ["versions.bzl"],
    visibility = ["//diffutils:__subpackages__"],
)

bzl_library(
    name = "resolved_toolchain",
    srcs = ["resolved_toolchain.bzl"],
    visibility = ["//diffutils:__subpackages__"],
)
