"""Public exports for diff rule"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:diff.bzl", "diff_rule")

def diff(name, srcs, args = ["--unified"], patch = None, source_patch_output_groups = ["diff_bzl__patch"], **kwargs):
    """Runs a diff between files and returns a patch.

    Examples:

    Create a patch between two files.

    ```starlark
    diff(
        name = "patch"
        srcs = ["a.txt", "b.txt"],
        patch = "a.patch"
    )
    ```

    Use `--from-file` to create a patch from one file to several files.

    ```starlark
    diff(
        name = "patch"
        args = ["--unified", "--from-file", "$(execpath a.txt)"],
        srcs = ["a.txt", "b.txt", "c.txt"],
        patch = "a.patch"
    )
    ```

    Run diff in a genrule.

    ```starlark
    genrule(
        name = "run_diff",
        srcs = ["a.txt", "b.txt"],
        outs = ["a.patch"],
        cmd = "$(DIFF_BIN) --unified $(execpath a.txt) $(execpath b.txt) > $@",
        toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
    )
    ```

    _By default, diff creates a unified format patch by passing `["--unified"]`
    to `args`. If overriding arguments, --unified must be added explicitly._

    Args:
        name: The name of the rule
        srcs: The files to compare
        args: Additional arguments to pass to diff
        patch: The output file to write the diff to. Defaults to ${name}.patch.
        source_patch_output_groups: Additional output groups to add source file patches to
        **kwargs: Additional arguments to pass to the underlying rule
    """
    for i in range(len(srcs)):
        if partial.is_instance(srcs[i]):
            target = name + ".%d" % i
            partial.call(srcs[i], name = target, out = target + ".in")
            srcs[i] = target

    diff_rule(
        name = name,
        args = args,
        srcs = srcs,
        patch = patch or name + ".patch",
        source_patch_output_groups = source_patch_output_groups,
        **kwargs
    )
