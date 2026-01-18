load("@bazel_lib//:bzl_library.bzl", "bzl_library")
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("//diff/private:options.bzl", "diff_options")
load("//diff/private:resolved_toolchain.bzl", "resolved_toolchain")

bool_flag(
    name = "validate_diffs",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)

config_setting(
    name = "validate_diffs.enabled",
    flag_values = {
        ":validate_diffs": "True",
    },
)

diff_options(
    name = "diff_options",
    validate_diffs = select({
        ":validate_diffs.enabled": True,
        "//conditions:default": False,
    }),
    visibility = ["//diff:__subpackages__"],
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
    deps = [
        "//diff/private:diff",
        "@bazel_skylib//lib:partial",
    ],
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
