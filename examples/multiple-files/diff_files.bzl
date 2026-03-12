"A specialization of filegroup that also provides FilesToDiffInfo instructions to diff"

load("@diff.bzl//diff:defs.bzl", "FilesToDiffInfo")

def _diff_files_impl(ctx):
    # we expect file paths to appear in the same path under bazel-bin and the source tree
    subpaths = [f.short_path for f in ctx.files.srcs]
    return [
        FilesToDiffInfo(
            src_subpaths = [f.replace("gen", "txt") for f in subpaths],
            dep_subpaths = subpaths,
        ),
        DefaultInfo(files = depset(ctx.files.srcs)),
    ]

diff_files = rule(
    implementation = _diff_files_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
    },
)
