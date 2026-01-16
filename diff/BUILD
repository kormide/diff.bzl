load("@bazel_lib//:bzl_library.bzl", "bzl_library")
load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("//diff/private:resolved_toolchain.bzl", "resolved_toolchain")

filegroup(name = "empty")

build_test(
    name = "smoke_test",
    targets = [
        # targets you add above
        ":empty",
    ],
)

resolved_toolchain(
    name = "resolved_toolchain",
    # Marked manual so that `bazel test //...` passes
    # even if no toolchain is registered.
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "repositories",
    srcs = ["repositories.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//diff/private:toolchains_repo",
        "//diff/private:versions",
    ],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "extensions",
    srcs = ["extensions.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":repositories",
        "@bazel_tools//tools/build_defs/repo:cache.bzl",
    ],
)

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    visibility = ["//visibility:public"],
)
