"""Implements the diff3 rule."""

DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

def _diff3_rule_impl(ctx):
    DIFF3_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.diff3_bin

    if len(ctx.attr.srcs) != 3:
        fail("diff3 requires three input files")

    outputs = [ctx.outputs.out]

    command = """\
{} {} {} {} {} > {}
if [[ $? == '2' ]]; then
    exit 2
fi
""".format(
        DIFF3_BIN.path,
        " ".join(ctx.attr.args),
        ctx.files.srcs[0].path,
        ctx.files.srcs[1].path,
        ctx.files.srcs[2].path,
        ctx.outputs.out.path,
    )

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff3",
        progress_message = "Three-way diffing %{input} to %{output}",
        tools = [DIFF3_BIN],
        toolchain = DIFFUTILS_TOOLCHAIN_TYPE,
    )

diff3_rule = rule(
    implementation = _diff3_rule_impl,
    attrs = {
        "args": attr.string_list(
            doc = """\
              Additional arguments to pass to the diff3 command.
            """,
            default = [],
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = """\
              Three files to compare: [my] [old] [your].
            """,
        ),
        "out": attr.output(
            doc = """\
              The output of diff3 is written to this file.
            """,
            mandatory = True,
        ),
    },
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)
