"""Implements the cmp rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

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

def _cmp_rule_impl(ctx):
    CMP_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.cmp_bin

    command = """\
{} {} {} {} > {}
EXIT_CODE=$?
if [[ $EXIT_CODE == '2' ]]; then
    exit 2
fi
echo $EXIT_CODE > {}
""".format(
        CMP_BIN.path,
        " ".join(ctx.attr.args),
        ctx.file.file1.path,
        ctx.file.file2.path,
        ctx.outputs.out.path,
        ctx.outputs.exit_code.path,
    )

    is_copy_to_source = ctx.file.file1.is_source or ctx.file.file2.is_source
    outputs = [ctx.outputs.out, ctx.outputs.exit_code]
    ctx.actions.run_shell(
        inputs = [ctx.file.file1, ctx.file.file2],
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsCmp",
        progress_message = "Cmping %{input} to %{output}",
        tools = [CMP_BIN],
        toolchain = DIFFUTILS_TOOLCHAIN_TYPE,
    )

    validation_outputs = []
    copy_to_source_outputs = [ctx.outputs.out] if is_copy_to_source else []

    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate_cmps

    if validate:
        validation_outputs.append(_validate_no_diff(ctx, ctx.outputs.exit_code, """\
        ERROR: cmp command exited with non-zero status.

        To update the first file, run:
        ( cd \\$(bazel info workspace); cp {file2} {file1} )
        """.format(file1 = ctx.file.file1.path, file2 = ctx.file.file2.path)))

    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset(validation_outputs),
            # By reading the Build Events, a Bazel wrapper can identify this cmp output group
            diff_bzl__cmp = depset(copy_to_source_outputs),
        ),
    ]

cmp_rule = rule(
    implementation = _cmp_rule_impl,
    attrs = {
        "args": attr.string_list(
            doc = """\
              Additional arguments to pass to the cmp command.
            """,
            default = [],
        ),
        "file1": attr.label(allow_single_file = True),
        "file2": attr.label(allow_single_file = True),
        "out": attr.output(
            doc = """\
              The output of cmp is written to this file.
            """,
            mandatory = True,
        ),
        "exit_code": attr.output(
            doc = """\
              The exit status of the cmp command is written to this file.
              The written status may only be 0 or 1 as a 2 will fail the cmp action.

              From 'man diff':
              > Exit status is 0 if inputs are the same, 1 if different, 2 if trouble.
            """,
            mandatory = True,
        ),
        "validate": attr.int(
            doc = """\
              Whether to treat non-empty cmp output (exit 1) as a build validation failure.

              -1: default to the flag value --@diff.bzl//diff:validate_cmps
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
