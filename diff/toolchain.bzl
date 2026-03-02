"""This module implements the language-specific toolchain rule.
"""

DiffutilsInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "cmp_bin": "diffutils cmp binary",
        "diff_bin": "diffutils diff binary",
        "diff3_bin": "diffutils diff3 binary",
        "sdiff_bin": "diffutils sdiff binary",
    },
)

def _diffutils_toolchain_impl(ctx):
    # Make the $(tool_BIN) variables available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "CMP_BIN": ctx.file.cmp_bin.path,
        "DIFF_BIN": ctx.file.diff_bin.path,
        "DIFF3_BIN": ctx.file.diff3_bin.path,
        "SDIFF_BIN": ctx.file.sdiff_bin.path,
    })

    TOOLS = [
        ctx.file.cmp_bin,
        ctx.file.diff_bin,
        ctx.file.diff3_bin,
        ctx.file.sdiff_bin,
    ]

    default = DefaultInfo(
        files = depset(TOOLS),
        runfiles = ctx.runfiles(files = TOOLS),
    )
    diffutilsinfo = DiffutilsInfo(
        cmp_bin = ctx.file.cmp_bin,
        diff_bin = ctx.file.diff_bin,
        diff3_bin = ctx.file.diff3_bin,
        sdiff_bin = ctx.file.sdiff_bin,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        diffutilsinfo = diffutilsinfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

diffutils_toolchain = rule(
    implementation = _diffutils_toolchain_impl,
    attrs = {
        "cmp_bin": attr.label(
            doc = "A hermetically downloaded cmp binary.",
            mandatory = True,
            allow_single_file = True,
        ),
        "diff_bin": attr.label(
            doc = "A hermetically downloaded diff binary.",
            mandatory = True,
            allow_single_file = True,
        ),
        "diff3_bin": attr.label(
            doc = "A hermetically downloaded diff3 binary.",
            mandatory = True,
            allow_single_file = True,
        ),
        "sdiff_bin": attr.label(
            doc = "A hermetically downloaded sdiff binary.",
            mandatory = True,
            allow_single_file = True,
        ),
    },
    doc = """Defines a diff toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
