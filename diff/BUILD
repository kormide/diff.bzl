load("@bazel_lib//:bzl_library.bzl", "bzl_library")
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("//diff/private:options.bzl", "diff_options")

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
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    visibility = ["//visibility:public"],
)
