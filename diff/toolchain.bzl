"""This module implements the language-specific toolchain rule.
"""

DiffutilsInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "diff_path": "(string) execroot-relative path to a GNU diff executable for the platform.",
        "tool_files": """\
            (list of labels) Files required in runfiles to make the tool executable available.
            May be empty if the diff_path points to a locally installed tool binary.""",
    },
)

def _diff_toolchain_impl(ctx):
    if ctx.attr.diff_tool and ctx.attr.diff_path:
        fail("Can only set one of diff_tool or diff_path but both were set.")
    if not ctx.attr.diff_tool and not ctx.attr.diff_path:
        fail("Must set one of diff_tool or diff_path.")

    tool_files = []
    diff_path = ctx.attr.diff_path

    if ctx.attr.diff_tool:
        tool_files = ctx.attr.diff_tool.files.to_list()
        diff_path = tool_files[0].path

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "DIFF_BIN": diff_path,
    })
    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    diffinfo = DiffutilsInfo(
        diff_path = diff_path,
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

diff_toolchain = rule(
    implementation = _diff_toolchain_impl,
    attrs = {
        "diff_tool": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = False,
            allow_single_file = True,
        ),
        "diff_path": attr.string(
            doc = "Path to an existing executable for the target platform.",
            mandatory = False,
        ),
    },
    doc = """Defines a diff compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
