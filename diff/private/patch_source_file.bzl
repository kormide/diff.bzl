"""Implementation of the patch_source_file rule"""

load(":diff.bzl", "DiffInfo")

def _patch_source_file_impl(ctx):
    source_patch_info = ctx.attr.patch[DiffInfo]
    source_patchable = source_patch_info.source_patchable
    source_patch_args = source_patch_info.source_patch_args
    patch = source_patch_info.patch

    if not source_patchable:
        fail("Error: patch {} cannot be applied to the source tree".format(patch.path))

    executable = ctx.actions.declare_file("{}_patch.sh".format(ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._patch_template,
        output = executable,
        is_executable = True,
        substitutions = {
            "{{PATCH_FILE}}": patch.short_path,
            "{{PATCH_ARGS}}": " ".join(source_patch_args),
        },
    )

    return DefaultInfo(
        executable = executable,
        default_runfiles = ctx.runfiles(files = [patch]),
    )

patch_source_file = rule(
    implementation = _patch_source_file_impl,
    attrs = {
        "patch": attr.label(
            providers = [DiffInfo],
            doc = "Patch produced by a diff rule",
            mandatory = True,
        ),
        "_patch_template": attr.label(
            doc = "Template Bash script used to apply the patch",
            cfg = "exec",
            allow_single_file = True,
            default = "//diff/private:patch_source_file.sh.tpl",
        ),
    },
    doc = "Apply a patch created by the `diff` rule to the source tree. Uses a non-hermetic patch binary on the PATH.",
    executable = True,
)
