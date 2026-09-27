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

    return DefaultInfo(executable = executable, default_runfiles = ctx.runfiles(files = [ctx.file.src]))

write_source_file = rule(
    implementation = _write_source_file_impl,
    doc = "",
    attrs = {
        "src": attr.label(
            mandatory = True,
            doc = "",
            allow_single_file = True,
        ),
        "dst": attr.string(
            mandatory = True,
            doc = "",
        ),
        "_write_template": attr.label(
            doc = "",
            cfg = "exec",
            allow_single_file = True,
            default = "//diff/private:write_source_file.sh.tpl",
        ),
    },
    executable = True,
)
