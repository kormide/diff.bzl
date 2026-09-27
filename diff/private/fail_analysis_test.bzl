"Test rule that always fails during the analysis phase and prints a message"

def _fail_analysis_test_impl(ctx):
    fail(ctx.attr.message)

fail_analysis_test = rule(
    attrs = {
        "message": attr.string(mandatory = True),
    },
    implementation = _fail_analysis_test_impl,
    test = True,
)


