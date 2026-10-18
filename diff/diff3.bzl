"""Public exports for diff3 rule"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:diff3.bzl", "diff3_rule")

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
