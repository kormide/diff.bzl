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
    command = "diff {} {} > {}".format(ctx.file.file1.path, ctx.file.file2.path, ctx.outputs.out.path)
    outputs = [ctx.outputs.out]
    if ctx.outputs.exit_code:
        command += "; echo $? > {}".format(ctx.outputs.exit_code.path)
        outputs.append(ctx.outputs.exit_code)

    ctx.actions.run_shell(
        inputs = [ctx.file.file1, ctx.file.file2],
        outputs = outputs,
        command = command,
    )
    return [DefaultInfo(files = depset(outputs))]

diff_rule = rule(
    implementation = _diff_rule_impl,
    attrs = {
        "file1": attr.label(allow_single_file = True),
        "file2": attr.label(allow_single_file = True),
        "diff": attr.label(allow_single_file = True),
        "exit_code": attr.output(
            doc = """\
              If provided, the exit status of the diff command is written to this file.

              From 'man diff':
              > Exit status is 0 if inputs are the same, 1 if different, 2 if trouble.

              If absent, then Bazel will honor the exit code of the diff command,
              which means the build will fail if the diff is non-zero.
            """,
        ),
        "out": attr.output(
            doc = """\
              The standard output of the diff command is written to this file.
            """,
            mandatory = True,
        ),
    },
)
