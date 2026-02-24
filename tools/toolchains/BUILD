load("@diff.bzl//diff:toolchain.bzl", "diff_toolchain")

diff_toolchain(
    name = "diffutils_toolchain",
    target_tool = "@diffutils//:diff",
)

toolchain(
    name = "diffutils_registration",
    toolchain = ":diffutils_toolchain",
    toolchain_type = "//diff/toolchain:execution_type",
)
