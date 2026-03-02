"""Implements the diff rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

# We run diff in actions, so we want to use the execution platform toolchain.
DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

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
    DIFF_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.diff_bin
    command = "{} {} {} {} > {}; echo $? > {}".format(
        DIFF_BIN.path,
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
        inputs = [ctx.file.file1, ctx.file.file2],
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff",
        progress_message = "Diffing %{input} to %{output}",
        tools = [DIFF_BIN],
        toolchain = "@diff.bzl//diffutils/toolchain:execution_type",
    )

    validation_outputs = []
    copy_to_source_outputs = [ctx.outputs.patch] if is_copy_to_source else []
    if ctx.attr.validate or ctx.attr._options[DiffOptionsInfo].validate_diffs:
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
        "validate": attr.bool(
            doc = """\
              If true, the diff command is validated to ensure it exits with 0.
              To enable this behavior for the whole build, run Bazel with --@diff.bzl//diff:validate_diffs.

              An individual Bazel invocation can run with --norun_validations to skip this behavior.
            """,
        ),
        "_options": attr.label(default = "//diff:diff_options"),
    },
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)
