"""Implements the sdiff_binary rule."""

DIFFUTILS_TOOLCHAIN_TYPE = "@diff.bzl//diff/toolchain:execution_type"

def _sdiff_binary_impl(ctx):
    SDIFF_BIN = ctx.toolchains[DIFFUTILS_TOOLCHAIN_TYPE].diffutilsinfo.sdiff_bin
    executable = ctx.actions.declare_file(ctx.label.name)

    # If file arguments are provided, use the wrapper script. Otherwise, make
    # sdiff itself the executable.
    if ctx.file.file1:
        ctx.actions.expand_template(
            template = ctx.file._sdiff_wrapper,
            output = executable,
            substitutions = {
                "{sdiff}": SDIFF_BIN.short_path,
                "{file1}": ctx.file.file1.short_path,
                # The second file could be passed via `args`.
                "{file2}": ctx.file.file2.short_path if ctx.file.file2 else "",
            },
            is_executable = True,
        )
    else:
        ctx.actions.symlink(
            output = executable,
            target_file = SDIFF_BIN,
            is_executable = True,
        )

    runfiles = [SDIFF_BIN] + ctx.files.data
    if ctx.file.file1:
        runfiles.append(ctx.file.file1)
    if ctx.file.file2:
        runfiles.append(ctx.file.file2)

    return [
        DefaultInfo(executable = executable, runfiles = ctx.runfiles(files = runfiles)),
    ]

sdiff_binary = rule(
    implementation = _sdiff_binary_impl,
    attrs = {
        "file1": attr.label(
            doc = "First file to compare",
            allow_single_file = True,
        ),
        "file2": attr.label(
            doc = "Second file to compare",
            allow_single_file = True,
        ),
        "data": attr.label_list(
            doc = "Additional file dependencies required at run-time",
            allow_files = True,
        ),
        "_sdiff_wrapper": attr.label(
            doc = "Wrapper script invoking sdiff with the two files",
            allow_single_file = True,
            default = "//diff/private:sdiff_binary.sh.tpl",
        ),
    },
    doc = "An executable rule that runs sdiff",
    executable = True,
    toolchains = [DIFFUTILS_TOOLCHAIN_TYPE],
)
