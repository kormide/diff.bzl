"""Implements the diff rule."""

def _diff_rule_impl(ctx):
    if ctx.outputs.exit_code:
        ctx.actions.run_shell(
            inputs = [ctx.file.file1, ctx.file.file2],
            outputs = [ctx.outputs.exit_code],
            command = "diff {} {}; echo $? > {}".format(ctx.file.file1.path, ctx.file.file2.path, ctx.outputs.exit_code.path),
        )
    else:
        ctx.actions.run_shell(
            inputs = [ctx.file.file1, ctx.file.file2],
            outputs = [ctx.outputs.out],
            command = "diff {} {} > {}".format(ctx.file.file1.path, ctx.file.file2.path, ctx.outputs.out.path),
        )
    return [DefaultInfo(files = depset([ctx.outputs.exit_code]) if ctx.outputs.exit_code else depset())]

diff_rule = rule(
    implementation = _diff_rule_impl,
    attrs = {
        "file1": attr.label(allow_single_file = True),
        "file2": attr.label(allow_single_file = True),
        "diff": attr.label(allow_single_file = True),
        "exit_code": attr.output(),
        "out": attr.output(),
    },
)
