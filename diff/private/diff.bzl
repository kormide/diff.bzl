"""Implements the diff rule."""

load("//diff/private:options.bzl", "DiffOptionsInfo")

FilesToDiffInfo = provider(
    doc = "Which files among the sources are meant to be diffed.",
    fields = {
        "src_subpaths": "The files to diff among the srcs. Names are expected to match relative to the workspace root.",
        "dep_subpaths": "The files to diff among the deps. Names are expected to match relative to the workspace root.",
    },
)

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
        """.format(exit_code_valid.path, exit_code_file.path, error_message),
    )
    return exit_code_valid

def _maybe_validate_diff(ctx, exit_code_file, patch_file):
    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate_diffs

    if not validate:
        return []

    # NB: the error message we print here allows the user to be in any working directory.
    return [_validate_no_diff(ctx, exit_code_file, """\
        ERROR: diff command exited with non-zero status.

        To accept the diff, run:
        ( cd \\$(bazel info workspace); patch -p0 < {patch} )
        """.format(patch = patch_file.path))]

def _diff_action(ctx, file1, file2, patch, exit_code):
    diff_bin = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.diff_bin
    command = """\
{} {} {} {} > {}
EXIT_CODE=$?
if [[ $EXIT_CODE == '2' ]]; then
    exit 2
fi
echo $EXIT_CODE > {}
""".format(
        diff_bin.path,
        " ".join(ctx.attr.args),
        file1.path,
        file2.path,
        patch.path,
        exit_code.path,
    )

    outputs = [patch, exit_code]
    ctx.actions.run_shell(
        inputs = [file1, file2],
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff",
        progress_message = "Diffing %{input} to %{output}",
        tools = [diff_bin],
        toolchain = "@diff.bzl//diffutils/toolchain:execution_type",
    )
    return outputs

def _diff_rule_impl(ctx):
    # If both inputs are generated, there's no writable file to patch.
    is_copy_to_source = ctx.file.file1.is_source or ctx.file.file2.is_source
    outputs = _diff_action(
        ctx,
        ctx.file.file1,
        ctx.file.file2,
        ctx.outputs.patch,
        ctx.outputs.exit_code,
    )

    copy_to_source_outputs = [ctx.outputs.patch] if is_copy_to_source else []
    validation_outputs = _maybe_validate_diff(ctx, ctx.outputs.exit_code, ctx.outputs.patch)
    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset(validation_outputs),
            # By reading the Build Events, a Bazel wrapper can identify this diff output group and apply the patch.
            diff_bzl__patch = depset(copy_to_source_outputs),
        ),
    ]

# Borrowed from https://github.com/bazelbuild/bazel-skylib/blob/f7718b7b8e2003b9359248e9632c875cb48a6e48/rules/select_file.bzl
def _select_file(deps, subpath):
    out = None
    canonical = subpath.replace("\\", "/")
    candidates = [f for d in deps for f in d[DefaultInfo].files.to_list()]
    for file_ in candidates:
        if file_.path.replace("\\", "/").endswith(canonical):
            out = file_
            break
    if not out:
        files_str = ",\n".join([
            str(f.path)
            for f in candidates
        ])
        fail("Can not find specified file {} in {}".format(canonical, files_str))
    return out

def _diff_multiple_impl(ctx):
    outputs = []
    infos = [dep[FilesToDiffInfo] for dep in ctx.attr.deps]

    patches = []
    exit_codes = []
    validation_outputs = []
    for info in infos:
        for src_subpath, dep_subpath in zip(info.src_subpaths, info.dep_subpaths):
            patch = ctx.actions.declare_file(src_subpath + ".patch")
            exit_code = ctx.actions.declare_file(src_subpath + ".exit_code")
            outputs.extend(_diff_action(
                ctx,
                _select_file(ctx.attr.srcs, src_subpath),
                _select_file(ctx.attr.deps, dep_subpath),
                patch,
                exit_code,
            ))
            patches.append(patch)
            exit_codes.append(exit_code)
            validation_outputs.extend(_maybe_validate_diff(ctx, exit_code, patch))
    return [
        DefaultInfo(files = depset(outputs)),
        OutputGroupInfo(
            _validation = depset(validation_outputs),
            # By reading the Build Events, a Bazel wrapper can identify this diff output group and apply the patch.
            #diff_bzl__patch = depset(copy_to_source_outputs),
        ),
    ]

common_attrs = {
    "args": attr.string_list(
        doc = """\
            Additional arguments to pass to the diff command.
        """,
        default = [],
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
}

diff_multiple = rule(
    implementation = _diff_multiple_impl,
    attrs = common_attrs | {
        "srcs": attr.label_list(allow_files = True),
        "deps": attr.label_list(providers = [FilesToDiffInfo]),
    },
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)

diff_rule = rule(
    implementation = _diff_rule_impl,
    attrs = common_attrs | {
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
    },
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)
