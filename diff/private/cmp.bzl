"""Implements the cmp rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

def _validate(ctx, error_message):
    cmp_valid_file = ctx.actions.declare_file(ctx.outputs.out.path + ".valid")
    ctx.actions.run_shell(
        inputs = [ctx.outputs.out],
        outputs = [cmp_valid_file],
        # assert that the cmp output is empty
        command = """
        touch {}
        if [ "$(head -c 1 {})" != "" ]; then
            >&2 echo "{}"
            exit 1
        fi
        """.format(cmp_valid_file.path, ctx.outputs.out.path, error_message),
    )
    return cmp_valid_file

def _cmp_rule_impl(ctx):
    CMP_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.cmp_bin

    command = """\
{} {} {} {} > {}
if [[ $? == '2' ]]; then
    exit 2
fi
""".format(
        CMP_BIN.path,
        " ".join(ctx.attr.args),
        ctx.file.file1.path,
        ctx.file.file2.path,
        ctx.outputs.out.path,
    )

    outputs = [ctx.outputs.out]

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

    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate

    if validate:
        # Show a command to replace file1 if it's a source file.
        # NB: the error message we print here allows the user to be in any working directory.
        msg = """
        To replace file1, run:
        ( cd \\$(bazel info workspace); cp {file2} {file1} )
        """.format(file1 = ctx.file.file1.path, file2 = ctx.file.file2.path) if ctx.file.file1.is_source else ""

        validation_outputs.append(_validate(ctx, """\
        ERROR: cmp command exited with non-zero status.
        {msg}""".format(msg = msg)))

    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset(validation_outputs),
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
