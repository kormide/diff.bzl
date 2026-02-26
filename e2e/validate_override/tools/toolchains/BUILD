load("@diff.bzl//diff:toolchain.bzl", "diffutils_toolchain")

diffutils_toolchain(
    name = "diffutils_toolchain",
    diff_path = "/usr/bin/diff",
)

toolchain(
    name = "diffutils_registration",
    toolchain = ":diffutils_toolchain",
    toolchain_type = "@diff.bzl//diff/toolchain:execution_type",
)
