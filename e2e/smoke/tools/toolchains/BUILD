load("@diff.bzl//diff:toolchain.bzl", "diff_toolchain")

diff_toolchain(
    name = "diffutils_toolchain",
    target_tool_path = "/usr/bin/diff",
)

toolchain(
    name = "diffutils_registration",
    toolchain = ":diffutils_toolchain",
    toolchain_type = "@diff.bzl//diff/toolchain:execution_type",
)
