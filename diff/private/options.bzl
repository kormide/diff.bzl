"Build-wide options set by command-line flags"

DiffOptionsInfo = provider(
    doc = "Global options for running diffs",
    fields = {
        "validate_cmps": "whether to validate the cmps",
        "validate_diffs": "whether to validate the diffs",
    },
)

def _diff_options_impl(ctx):
    return DiffOptionsInfo(
        validate_cmps = ctx.attr.validate_cmps,
        validate_diffs = ctx.attr.validate_diffs,
    )

diff_options = rule(
    implementation = _diff_options_impl,
    attrs = {
        "validate_cmps": attr.bool(),
        "validate_diffs": attr.bool(),
    },
)
