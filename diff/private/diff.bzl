"""Implements the diff rule."""

def _validate_diff_binary(ctx):
    """Validate that the diff binary is GNU diffutils.

    This is to avoid issues in case of a wrong toolchain registration
    or a non-hermetic system dependency.
    Note that this action is trivially a cache hit, so it shouldn't run frequently.

    Args:
        ctx: The context of the rule.
    Returns:
        The output file containing the validation result, which must be placed in a _validation output group.
    """
    is_bsd_diff = ctx.actions.declare_file(ctx.label.name + ".is_bsd_diff")

    ctx.actions.run_shell(
        inputs = [],  # TODO: should include the toolchain diff binary
        outputs = [is_bsd_diff],
        command = """\
        {diff_bin} --version > {validation_output}
        grep -q "GNU" {validation_output} || {{
          echo 'ERROR: diff is not GNU diffutils:'
          cat {validation_output}
          echo 'run Bazel with --norun_validations to ignore this error'
          exit 1
        }} >&2
        """.format(
            diff_bin = "diff",
            validation_output = is_bsd_diff.path,
        ),
    )
    return is_bsd_diff

def _diff_rule_impl(ctx):
    # from 'man diff':
    # > Exit status is 0 if inputs are the same, 1 if different, 2 if trouble.
    # For now, we have two modes:
    # 1. Exit code mode: we want to return the exit code of the diff command, so that it doesn't make the build fail when the diff is non-zero
    # 2. Output mode: we want to return the output of the diff command, but let Bazel honor the exit code.
    # This is temporary to get the smoke test running, will iterate on a more user-ergonomic API.
    if int(bool(ctx.attr.exit_code)) + int(bool(ctx.attr.out)) != 1:
        fail("Exactly one of 'exit_code' or 'out' must be set")
    outputs = [o for o in [ctx.outputs.exit_code, ctx.outputs.out] if o]

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

    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset([_validate_diff_binary(ctx)]),
        ),
    ]

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
