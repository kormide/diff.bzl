"""Implementation of the write_source_file rule"""

def _write_source_file_impl(ctx):
    executable = ctx.actions.declare_file("{}_write.sh".format(ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._write_template,
        output = executable,
        is_executable = True,
        substitutions = {
            "{{SRCS}}": " ".join(["\"{}\"".format(src.short_path) for src in ctx.files.srcs]),
            "{{DSTS}}": " ".join(["\"{}\"".format(dst) for dst in ctx.attr.dsts]),
        },
    )

    return DefaultInfo(
        executable = executable,
        default_runfiles = ctx.runfiles(files = ctx.files.srcs),
    )

write_source_file = rule(
    implementation = _write_source_file_impl,
    doc = "Overwrite files or directories in the source tree with the contents of other files or directories",
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            doc = "Files or directories to copy from",
            allow_files = True,
        ),
        "dsts": attr.string_list(
            mandatory = True,
            doc = "Files or directories to copy to",
        ),
        "_write_template": attr.label(
            doc = "Template Bash script used to perform the copying",
            cfg = "exec",
            allow_single_file = True,
            default = "//diff/private:write_source_file.sh.tpl",
        ),
    },
    executable = True,
)
