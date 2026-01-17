"""This module implements the language-specific toolchain rule.
"""

DiffutilsInfo = provider(
    doc = "Information about how to invoke the tool executables.",
    fields = {
        "diff_path": "Path to the diff executable",
        "cmp_path": "Path to the cmp executable",
        "diff3_path": "Path to the diff3 executable",
        "sdiff_path": "Path to the sdiff executable",
        "tool_files": """Files required in runfiles to make the tool executable available. May be empty for a locally installed tool binary.""",
    },
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _diffutils_toolchain_impl(ctx):
    if ctx.attr.target_tool and ctx.attr.target_tool_path:
        fail("Can only set one of target_tool or target_tool_path but both were set.")
    if not ctx.attr.target_tool and not ctx.attr.target_tool_path:
        fail("Must set one of target_tool or target_tool_path.")

    tool_files = []
    target_tool_path = ctx.attr.target_tool_path

    if ctx.attr.target_tool:
        tool_files = ctx.attr.target_tool.files.to_list()
        target_tool_path = _to_manifest_path(ctx, tool_files[0])

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "DIFF_BIN": target_tool_path,
    })
    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    diffinfo = DiffutilsInfo(
        target_tool_path = target_tool_path,
        tool_files = tool_files,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        diffinfo = diffinfo,
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
            doc = "A hermetically downloaded executable target for the diff tool.",
            mandatory = False,
            allow_single_file = True,
        ),
        "cmp_tool": attr.label(
            doc = "A hermetically downloaded executable target for the cmp tool.",
            allow_single_file = True,
        ),
        "diff3_tool": attr.label(
            doc = "A hermetically downloaded executable target for the diff3 tool.",
            allow_single_file = True,
        ),
        "sdiff_tool": attr.label(
            doc = "A hermetically downloaded executable target for the sdiff tool.",
            allow_single_file = True,
        ),
        "use_system_diff": attr.bool(
            doc = "Whether to use the system diff tool from the PATH.",
            default = False,
        ),
    },
    doc = """Defines a diffutils toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
