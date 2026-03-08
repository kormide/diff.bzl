load("@bazel_lib//:bzl_library.bzl", "bzl_library")
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag")
load("//diff/private:options.bzl", "diff_options")

bool_flag(
    name = "validate",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)

config_setting(
    name = "validate.enabled",
    flag_values = {
        ":validate": "True",
    },
)

diff_options(
    name = "diff_options",
    validate = select({
        ":validate.enabled": True,
        "//conditions:default": False,
    }),
    visibility = ["//diff:__subpackages__"],
)

bzl_library(
    name = "defs",
    srcs = ["defs.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//diff/private:cmp",
        "//diff/private:diff",
        "@bazel_skylib//lib:partial",
    ],
)

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    visibility = ["//visibility:public"],
)
