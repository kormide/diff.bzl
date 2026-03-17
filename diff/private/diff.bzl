"""Implements the diff rule."""

load("@bazel_lib//lib:expand_make_vars.bzl", "expand_locations")
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

def _determine_patch_type(args):
    for arg in args:
        arg = arg.lstrip(" ")
        if arg.lower().startswith("-c ") or arg.startswith("--context"):
            return "context"
        elif arg.lower().startswith("-u ") or arg.startswith("--unified"):
            return "unified"
        elif arg.startswith("--normal"):
            return "normal"
        elif arg.startswith("-q") or arg.startswith("--brief"):
            return "brief"

    return "normal"

def _patch_cmd(type, source_file, patch_file):
    if type == "normal":
        return "(cd \\$(bazel info workspace); patch -p0 {} < {})".format(source_file, patch_file)
    elif type == "context" or type == "unified":
        return "(cd \\$(bazel info workspace); patch -p0 < {})".format(patch_file)
    return None

def _detect_multifile(args):
    from_file = False
    to_file = False
    file_path = None

    for i, arg in enumerate(args):
        arg = arg.lstrip(" ")
        if arg.startswith("--from-file"):
            from_file = True
            file_path = args[i + 1]
            break
        elif arg.startswith("--to-file"):
            to_file = True
            file_path = args[i + 1]
            break

    return (from_file, to_file, file_path)

def _build_command(bin_dir, diff_bin, patch, type):
    epoch_timestamp = "1970-01-01 00:00:00.000000000 +0000"
    if type == "unified":
        match_timestamp_and_offset = "[0-9]{4}-[0-9]{2}-[0-9]{2}\\s+[0-9]{2}:[0-9]{2}:[0-9]{2}\\.[0-9]+\\s+[-+][0-9]{4}"
        command = """
DIFF=$({} $@)
if [[ $? == '2' ]]; then
    exit 2
fi
echo "$DIFF" | sed -r 's#^((---|\\+\\+\\+)\\s+)({}/)?(\\S+)\\s+{}#\\1\\4 {}#' > {}
""".format(
            diff_bin,
            bin_dir,
            match_timestamp_and_offset,
            epoch_timestamp,
            patch.path,
        )
    elif type == "context":
        # assumes LC_TIME=C
        match_timestamp = "\\S+\\s+\\S+\\s+[0-9]{2}\\s+[0-9]{2}:[0-9]{2}:[0-9]{2}\\s+[0-9]{4}"
        command = """
DIFF=$({} $@)
if [[ $? == '2' ]]; then
    exit 2
fi
echo "$DIFF" | sed -r 's#^((---|\\*\\*\\*)\\s+)({}/)?(\\S+)\\s+{}#\\1\\4 {}#' > {}
""".format(
            diff_bin,
            bin_dir,
            match_timestamp,
            epoch_timestamp,
            patch.path,
        )
    else:
        command = """
{} $@ > {}
if [[ $? == '2' ]]; then
    exit 2
fi
""".format(
            diff_bin,
            patch.path,
        )
    return command

def _is_patchable(type, files, from_file, to_file, for_or_to_file_path):
    filtered_files = [file for file in files if file.path != for_or_to_file_path]
    if from_file:
        # doesn't make sense for source patching
        return False
    elif to_file:
        # cannot apply a multifile normal patch since there are no file labels
        if type == "normal":
            return False

        # every other file must be a source file
        for file in filtered_files:
            if not file.is_source:
                return False
        return True
    else:
        return files[0].is_source

def _diff_rule_impl(ctx):
    DIFF_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.diff_bin

    args = ctx.actions.args()
    for arg in ctx.attr.args:
        args.add(expand_locations(ctx, arg, ctx.attr.srcs))
    args.add_all(ctx.files.srcs, expand_directories = False)

    (from_file, to_file, from_or_to_file_path) = _detect_multifile(ctx.attr.args)

    if not from_file and not to_file and len(ctx.attr.srcs) != 2:
        fail("error: srcs attr of diff rule must contain exactly two targets unless --from-file or --to-file are specified")

    type = _determine_patch_type(ctx.attr.args)

    command = _build_command(
        ctx.bin_dir.path,
        DIFF_BIN.path,
        ctx.outputs.patch,
        type,
    )

    outputs = [ctx.outputs.patch]

    ctx.actions.run_shell(
        inputs = ctx.files.srcs,
        arguments = [args],
        env = {
            # --unified always uses the same timestamp format:
            # https://www.gnu.org/software/diffutils/manual/html_node/Detailed-Unified.html#Detailed-Description-of-Unified-Format
            # --context diffs use locale time format
            # Override the --context time format to be predictable for parsing using a locale
            # available on all machines.
            "LC_TIME": "C",
        },
        outputs = outputs,
        command = command,
        mnemonic = "DiffutilsDiff",
        progress_message = "Diffing %{input} to %{output}",
        tools = [DIFF_BIN],
        toolchain = DIFFUTILS_TOOLCHAIN_TYPE,
    )

    validation_outputs = []
    patchable = _is_patchable(type, ctx.files.srcs, from_file, to_file, from_or_to_file_path)
    source_patch_outputs = [ctx.outputs.patch] if patchable else []

    if ctx.attr.validate == 1:
        validate = True
    elif ctx.attr.validate == 0:
        validate = False
    else:
        validate = ctx.attr._options[DiffOptionsInfo].validate

    if validate:
        patch_msg = ""
        if patchable:
            # Show a command to patch the source file if it's a (bazel) source file.
            # NB: the error message we print here allows the user to be in any working directory.
            patch_cmd = _patch_cmd(type, ctx.files.srcs[0].path, ctx.outputs.patch.path)
            if patch_cmd != None:
                patch_msg = """
    To accept the diff, run:
    {}
                """.format(patch_cmd)

        validation_outputs.append(_validate(ctx, """\
    ERROR: diff command exited with non-zero status.
    {}""".format(patch_msg)))

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
        "srcs": attr.label_list(allow_files = True),
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
