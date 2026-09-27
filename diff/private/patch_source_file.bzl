load(":diff.bzl", "get_patch_cmd", "is_source_patchable", "DiffInfo")


def _patch_source_file_impl(ctx):
    diff_info = ctx.attr.patch[DiffInfo]

    from_files = diff_info.from_files
    to_files = diff_info.to_files
    patch = diff_info.patch
    patch_type = diff_info.patch_type
    newfile = diff_info.newfile
    is_from_file = diff_info.is_from_file
    is_to_file = diff_info.is_to_file
    files = diff_info.files
    from_or_to_file_path = diff_info.from_or_to_file_path

    if is_from_file:
        fail("TODO: more than one from file")

    if is_to_file:
        fail("TODO: more than one from file")

    if not is_source_patchable(patch_type, files, is_from_file, is_to_file, from_or_to_file_path, newfile):
        fail("TODO: not source patchable")

    from_file = from_files[0]
    if not from_file.is_source:
        fail("TODO: not source")

    patch_cmd = get_patch_cmd(patch_type, from_file, patch, newfile, include_stdin_redirect = False)

    executable = ctx.actions.declare_file("{}_patch.sh".format(ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._patch_template,
        output = executable,
        is_executable = True,
        substitutions = {
            "{{PATCH_FILE}}": patch.short_path,
            "{{PATCH_CMD}}": patch_cmd,
        },
    )

    return DefaultInfo(executable = executable, default_runfiles = ctx.runfiles(files = [patch]))

patch_source_file = rule(
    implementation = _patch_source_file_impl,
    attrs = {
        "patch": attr.label(
            providers = [DiffInfo],
            doc = "",
            mandatory = True,
        ),
        "_patch_template": attr.label(
            doc = "",
            cfg = "exec",
            allow_single_file = True,
            default = "//diff/private:patch_source_file.sh.tpl",
        ),
    },
    doc = "",
    executable = True,
)
