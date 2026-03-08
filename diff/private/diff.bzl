"""Implements the diff rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

def _validate(ctx, error_message):
    diff_valid_file = ctx.actions.declare_file(ctx.outputs.patch.path + ".valid")
    ctx.actions.run_shell(
        inputs = [ctx.outputs.patch],
        outputs = [diff_valid_file],
        # assert that the diff output is empty
        command = """
        touch {}
        if [ "$(head -c 1 {})" != "" ]; then
            >&2 echo "{}"
            exit 1
        fi
        """.format(diff_valid_file.path, ctx.outputs.patch.path, error_message),
    )
    return diff_valid_file

def _diff_rule_impl(ctx):
    DIFF_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.diff_bin

    command = """\
{} {} {} {} > {}
if [[ $? == '2' ]]; then
    exit 2
fi
""".format(
        DIFF_BIN.path,
        " ".join(ctx.attr.args),
        ctx.file.file1.path,
        ctx.file.file2.path,
        ctx.outputs.patch.path,
    )

    outputs = [ctx.outputs.patch]

    ctx.actions.run_shell(
        inputs = [ctx.file.file1, ctx.file.file2],
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff",
        progress_message = "Diffing %{input} to %{output}",
        tools = [DIFF_BIN],
        toolchain = DIFFUTILS_TOOLCHAIN_TYPE,
    )

    validation_outputs = []
    source_patch_outputs = [ctx.outputs.patch] if ctx.file.file1.is_source else []

    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate

    if validate:
        # Show a command to patch file1 if it's a source file.
        # NB: the error message we print here allows the user to be in any working directory.
        msg = """
        To accept the diff, run:
        ( cd \\$(bazel info workspace); patch -p0 < {patch} )
        """.format(patch = ctx.outputs.patch.path) if ctx.file.file1.is_source else ""

        validation_outputs.append(_validate(ctx, """\
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
