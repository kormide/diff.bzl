"Build-wide options set by command-line flags"

DiffOptionsInfo = provider(
    doc = "Global options for running diffs",
    fields = {
        "validate": "whether to validate cmps, diffs, etc.",
    },
)

def _diff_options_impl(ctx):
    return DiffOptionsInfo(
        validate = ctx.attr.validate,
    )

diff_options = rule(
    implementation = _diff_options_impl,
    attrs = {
        "validate": attr.bool(),
    },
)
