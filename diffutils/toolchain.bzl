"""This module implements the language-specific toolchain rule.
"""

DiffutilsInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "diff_bin": "Path to the diff executable",
        "cmp_bin": "Path to the cmp",
    },
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _diffutils_toolchain_impl(ctx):
    diff_tool_path = _to_manifest_path(ctx, ctx.file.diff_tool)

    cmp_tool_path = _to_manifest_path(ctx, ctx.file.cmp_tool)

    files = [ctx.file.diff_tool, ctx.file.cmp_tool]

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "DIFF_BIN": diff_tool_path,
        "CMP_BIN": cmp_tool_path,
    })
    default = DefaultInfo(
        files = depset(files),
        runfiles = ctx.runfiles(files = files),
    )
    diffutilsinfo = DiffutilsInfo(
        diff_bin = ctx.file.diff_tool,
        cmp_bin = ctx.file.cmp_tool,
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
        "diff_tool": attr.label(
            doc = "A diff executable target for the target platform.",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "cmp_tool": attr.label(
            doc = "A cmp executable target for the target platform.",
            mandatory = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
    },
    doc = """Defines a diffutils compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
