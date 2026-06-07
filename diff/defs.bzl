"Public diff.bzl API re-exports"

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:cmp.bzl", "cmp_rule")
load("//diff/private:diff.bzl", "diff_rule")
load("//diff/private:diff3.bzl", "diff3_rule")
load("//diff/private:sdiff.bzl", "sdiff_rule")

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

def diff(name, srcs, args = ["--unified"], patch = None, **kwargs):
    """Runs a diff between files and return a patch.

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
        srcs: The files to compare.
        args: Additional arguments to pass to diff
        patch: The output file to write the diff to. Defaults to ${name}.patch.
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
        **kwargs
    )

def diff3(name, srcs, args = [], out = None, **kwargs):
    """Compare three files line by line.

    Examples:

    Compare three files.

    ```starlark
    diff3(
        name = "compare",
        srcs = ["my.txt", "old.txt", "your.txt"],
        out = "comparison"
    )
    ```

    Output the merged file.

    ```starlark
    diff3(
        name = "compare",
        args = ["--merge"],
        srcs = ["my.txt", "old.txt", "your.txt"],
        out = "comparison"
    )
    ```

    Run diff3 in a genrule.

    ```starlark
    genrule(
        name = "run_sdiff",
        srcs = ["my.txt", "old.txt", "your.txt"],
        outs = ["comparison"],
        cmd = "$(DIFF3_BIN) $(execpath my.txt) $(execpath old.txt) $(execpath your.txt) > $@",
        toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
    )
    ```

    Args:
        name: The name of the rule
        srcs: The three files to compare.
        args: Additional arguments to pass to diff3.
        out: The file to write the diff3 output to to. Defaults to ${name}.out.
        **kwargs: Additional arguments to pass to the underlying rule.
    """
    for i in range(len(srcs)):
        if partial.is_instance(srcs[i]):
            target = name + ".%d" % i
            partial.call(srcs[i], name = target, out = target + ".in")
            srcs[i] = target

    diff3_rule(
        name = name,
        args = args,
        srcs = srcs,
        out = out or name + ".out",
        **kwargs
    )

def sdiff(name, srcs, args = [], out = None, **kwargs):
    """Produce a side-by-side diff of two files.

    Examples:

    Compare two files.
g
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
