"""Implements the diff rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

# We run diff in actions, so we want to use the execution platform toolchain.
DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

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
    diffinfo = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffinfo
    ctx.actions.run_shell(
        inputs = diffinfo.tool_files,
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
            diff_bin = diffinfo.diff_path,
            validation_output = is_bsd_diff.path,
        ),
    )
    return is_bsd_diff

def _validate_exit_code(ctx, exit_code_file, error_message = "Diff exited with bad status", code = 0):
    exit_code_valid = ctx.actions.declare_file(exit_code_file.path + ".valid")
    ctx.actions.run_shell(
        inputs = [exit_code_file],
        outputs = [exit_code_valid],
        # assert that the input file first character is 0
        command = """
        touch {}
        if [ $(head -c 1 {}) != '{}' ]; then
            >&2 echo "{}"
            exit 1
        fi
        """.format(exit_code_valid.path, ctx.outputs.exit_code.path, code, error_message),
    )
    return exit_code_valid

def _diff_rule_impl(ctx):
    diffinfo = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffinfo
    command = "{} {} {} {} > {}; echo $? > {}".format(
        diffinfo.diff_path,
        " ".join(ctx.attr.args),
        ctx.file.file1.path,
        ctx.file.file2.path,
        ctx.outputs.patch.path,
        ctx.outputs.exit_code.path,
    )

    # If both inputs are generated, there's no writable file to patch.
    is_copy_to_source = ctx.file.file1.is_source or ctx.file.file2.is_source
    outputs = [ctx.outputs.patch, ctx.outputs.exit_code]
    ctx.actions.run_shell(
        inputs = [ctx.file.file1, ctx.file.file2] + diffinfo.tool_files,
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff",
        progress_message = "Diffing %{input} to %{output}",
    )

    validation_outputs = [_validate_diff_binary(ctx)]
    copy_to_source_outputs = [ctx.outputs.patch] if is_copy_to_source else []

    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate_diffs

    if validate:
        validation_outputs.append(_validate_exit_code(ctx, ctx.outputs.exit_code, """\
        ERROR: diff command exited with non-zero status.

        To accept the diff, run:
        patch -d \\$(bazel info workspace) -p0 < {patch}
        """.format(patch = ctx.outputs.patch.path)))

    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset(validation_outputs),
            # By reading the Build Events, a Bazel wrapper can identify this diff output group and apply the patch.
            diff_bzl__patch = depset(copy_to_source_outputs),
        ),
    ]

diff_rule = rule(
    implementation = _diff_rule_impl,
    attrs = {
        "args": attr.string_list(
            doc = """\
              Additional arguments to pass to the diff command.
            """,
            default = [],
        ),
        "file1": attr.label(allow_single_file = True),
        "file2": attr.label(allow_single_file = True),
        "diff": attr.label(allow_single_file = True),
        "exit_code": attr.output(
            doc = """\
              The exit status of the diff command is written to this file.

              From 'man diff':
              > Exit status is 0 if inputs are the same, 1 if different, 2 if trouble.
            """,
            mandatory = True,
        ),
        "patch": attr.output(
            doc = """\
              The standard output of the diff command is written to this file.
            """,
            mandatory = True,
        ),
        "validate": attr.int(
            doc = """\
              Whether to treat a non-zero diff exit as a build validation failure.

              -1: default to the flag value --@diff.bzl//diff:validate_diffs
               0: never validate
               1: always validate

              An individual Bazel invocation can run with --norun_validations to skip this behavior.
            """,
            default = -1,
            values = [-1, 0, 1],
        ),
        "_options": attr.label(default = "//diff:diff_options"),
    },
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)
