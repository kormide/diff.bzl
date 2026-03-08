"""Implements the diff rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

# We run diff in actions, so we want to use the execution platform toolchain.
DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

def _validate_no_diff(ctx, exit_code_file, error_message):
    exit_code_valid = ctx.actions.declare_file(exit_code_file.path + ".valid")
    ctx.actions.run_shell(
        inputs = [exit_code_file],
        outputs = [exit_code_valid],
        # assert that the input file first character is 0
        command = """
        touch {}
        if [ $(head -c 1 {}) != '0' ]; then
            >&2 echo "{}"
            exit 1
        fi
        """.format(exit_code_valid.path, ctx.outputs.exit_code.path, error_message),
    )
    return exit_code_valid

def _diff_rule_impl(ctx):
    DIFF_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.diff_bin

    command = """\
{} {} {} {} > {}
EXIT_CODE=$?
if [[ $EXIT_CODE == '2' ]]; then
    exit 2
fi
echo $EXIT_CODE > {}
""".format(
        DIFF_BIN.path,
        " ".join(ctx.attr.args),
        ctx.file.file1.path,
        ctx.file.file2.path,
        ctx.outputs.patch.path,
        ctx.outputs.exit_code.path,
    )

    outputs = [ctx.outputs.patch, ctx.outputs.exit_code]
    ctx.actions.run_shell(
        inputs = [ctx.file.file1, ctx.file.file2],
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff",
        progress_message = "Diffing %{input} to %{output}",
        tools = [DIFF_BIN],
        toolchain = "@diff.bzl//diffutils/toolchain:execution_type",
    )

    validation_outputs = []
    source_patch_outputs = [ctx.outputs.patch] if ctx.file.file1.is_source else []

    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate_diffs

    if validate:
        # It only makes sense to patch if file1 is a source file.
        msg = """
        To accept the diff, run:
        patch -d \\$(bazel info workspace) -p0 < {patch}
        """.format(patch = ctx.outputs.patch.path) if ctx.file.file1.is_source else ""

        validation_outputs.append(_validate_no_diff(ctx, ctx.outputs.exit_code, """\
        ERROR: diff command exited with non-zero status.
        {msg}""".format(msg = msg)))

    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset(validation_outputs),
            # By reading the Build Events, a Bazel wrapper can identify this diff output group and apply the patch.
            diff_bzl__patch = depset(source_patch_outputs),
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
        "exit_code": attr.output(
            doc = """\
              The exit status of the diff command is written to this file.
              The written status may only be 0 or 1 as a 2 will fail the diff action.

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
              Whether to treat a non-empty diff (exit 1) as a build validation failure.

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
