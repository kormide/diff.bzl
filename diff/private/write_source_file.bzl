"""Implementation of the write_source_file rule"""

def _write_source_file_impl(ctx):
    executable = ctx.actions.declare_file("{}_write.sh".format(ctx.attr.name))
    ctx.actions.expand_template(
        template = ctx.file._write_template,
        output = executable,
        is_executable = True,
        substitutions = {
            "{{SRC}}": ctx.file.src.short_path,
            "{{DST}}": ctx.attr.dst,
        },
    )

    return DefaultInfo(
        executable = executable,
        default_runfiles = ctx.runfiles(files = [ctx.file.src]),
    )

write_source_file = rule(
    implementation = _write_source_file_impl,
    doc = "Overwrite a file or directory in the source tree with the contents of another file or directory",
    attrs = {
        "src": attr.label(
            mandatory = True,
            doc = "File or directory containing the desired contents",
            allow_single_file = True,
        ),
        "dst": attr.string(
            mandatory = True,
            doc = "Destination file or directory to write to",
        ),
        "_write_template": attr.label(
            doc = "Template Bash script used to copy the file or directory",
            cfg = "exec",
            allow_single_file = True,
            default = "//diff/private:write_source_file.sh.tpl",
        ),
    },
    executable = True,
)
