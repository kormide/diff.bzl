"""Public exports for sdiff rule"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:sdiff.bzl", "sdiff_rule")

def sdiff(name, srcs, args = [], out = None, **kwargs):
    """Produce a side-by-side diff of two files.

    Examples:

    Compare two files.

    ```starlark
    sdiff(
        name = "side_by_side",
        srcs = ["a.txt", "b.txt"],
        out = "comparison.txt"
    )
    ```

    Run sdiff in a genrule.

    ```starlark
    genrule(
        name = "run_sdiff",
        srcs = ["a.txt", "b.txt"],
        outs = ["comparison"],
        cmd = "$(SDIFF_BIN) $(execpath a.txt) $(execpath b.txt) > $@",
        toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
    )
    ```

    Args:
        name: The name of the rule
        srcs: The two files to compare.
        args: Additional arguments to pass to sdiff.
        out: The output file to write the side-by-side comparison to. Defaults to ${name}.out.
        **kwargs: Additional arguments to pass to the underlying rule.
    """
    for i in range(len(srcs)):
        if partial.is_instance(srcs[i]):
            target = name + ".%d" % i
            partial.call(srcs[i], name = target, out = target + ".in")
            srcs[i] = target

    sdiff_rule(
        name = name,
        args = args,
        srcs = srcs,
        out = out or name + ".out",
        **kwargs
    )
