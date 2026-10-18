"""Public exports for cmp rule"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:cmp.bzl", "cmp_rule")

def cmp(name, srcs, args = [], out = None, **kwargs):
    """Runs cmp (binary diff) between two files and returns the output.

    Examples:

    Compare two binaries.

    ```starlark
    cmp(
        name = "compare_bins",
        args = ["--bytes", "4", "--verbose"],
        srcs = ["bin_a", "bin_b"],
        out = "cmp_output"
    )
    ```

    Run cmp in a genrule.

    ```starlark
    genrule(
        name = "run_cmp",
        srcs = ["bin_a", "bin_b"],
        outs = ["cmp_output"],
        cmd = "$(CMP_BIN) --verbose $(execpath bin_a) $(execpath bin_b) > $@",
        toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
    )
    ```

    Args:
        name: The name of the rule
        srcs: The files to compare.
        args: Additional arguments to pass to cmp
        out: The output file to write the output of cmp to. Defaults to ${name}.out.
        **kwargs: Additional arguments to pass to the underlying rule.
    """
    for i in range(len(srcs)):
        if partial.is_instance(srcs[i]):
            target = name + ".%d" % i
            partial.call(srcs[i], name = target, out = target + ".in")
            srcs[i] = target

    cmp_rule(
        name = name,
        args = args,
        srcs = srcs,
        out = out or name + ".out",
        **kwargs
    )
