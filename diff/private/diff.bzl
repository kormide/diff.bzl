"""Implements the diff rule."""

def _diff_rule_impl(ctx):
    # from 'man diff':
    # > Exit status is 0 if inputs are the same, 1 if different, 2 if trouble.
    # For now, we have two modes:
    # 1. Exit code mode: we want to return the exit code of the diff command, so that it doesn't make the build fail when the diff is non-zero
    # 2. Output mode: we want to return the output of the diff command, but let Bazel honor the exit code.
    # This is temporary to get the smoke test running, will iterate on a more user-ergonomic API.
    if int(bool(ctx.attr.exit_code)) + int(bool(ctx.attr.out)) != 1:
        fail("Exactly one of 'exit_code' or 'out' must be set")
    if ctx.outputs.exit_code:
        ctx.actions.run_shell(
            inputs = [ctx.file.file1, ctx.file.file2],
            outputs = [ctx.outputs.exit_code],
            command = "diff {} {} {}; echo $? > {}".format(" ".join(ctx.attr.args), ctx.file.file1.path, ctx.file.file2.path, ctx.outputs.exit_code.path),
        )
    else:
        ctx.actions.run_shell(
            inputs = [ctx.file.file1, ctx.file.file2],
            outputs = [ctx.outputs.out],
            command = "diff {} {} {} > {}".format(" ".join(ctx.attr.args), ctx.file.file1.path, ctx.file.file2.path, ctx.outputs.out.path),
        )
    return [DefaultInfo(files = depset([ctx.outputs.exit_code]) if ctx.outputs.exit_code else depset([ctx.outputs.out]))]

diff_rule = rule(
    implementation = _diff_rule_impl,
    attrs = {
        "args": attr.string_list(default = []),
        "file1": attr.label(allow_single_file = True),
        "file2": attr.label(allow_single_file = True),
        "diff": attr.label(allow_single_file = True),
        "exit_code": attr.output(),
        "out": attr.output(),
    },
)
