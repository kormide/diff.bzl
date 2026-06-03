"""Implements the sdiff rule."""

DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

def _sdiff_rule_impl(ctx):
    SDIFF_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.sdiff_bin

    if len(ctx.attr.srcs) != 2:
        fail("sdiff requires two input files")

    outputs = [ctx.outputs.out]

    command = """\
{} {} {} {} > {}
if [[ $? == '2' ]]; then
    exit 2
fi
""".format(
        SDIFF_BIN.path,
        " ".join(ctx.attr.args),
        ctx.files.srcs[0].path,
        ctx.files.srcs[1].path,
        ctx.outputs.out.path,
    )

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsSdiff",
        progress_message = "Side-by-side diffing %{input} to %{output}",
        tools = [SDIFF_BIN],
        toolchain = DIFFUTILS_TOOLCHAIN_TYPE,
    )

sdiff_rule = rule(
    implementation = _sdiff_rule_impl,
    attrs = {
        "args": attr.string_list(
            doc = """\
              Additional arguments to pass to the sdiff command.
            """,
            default = [],
        ),
        "srcs": attr.label_list(
            allow_files = True,
            doc = """\
              Two files to compare.
            """,
        ),
        "out": attr.output(
            doc = """\
              The side-by-side diff is written to this file.
            """,
            mandatory = True,
        ),
    },
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)
