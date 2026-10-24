"""Public expkrts for sdiff_binary rule"""

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:sdiff_binary.bzl", _sdiff_binary = "sdiff_binary")

def sdiff_binary(name, file1 = None, file2 = None, **kwargs):
    """Create a binary that runs a side-by-side diff of two files using sdiff.

    Examples:

    Run sdiff against two files.

    ```starlark
    sdiff_binary(
        name = "compare",
        file1 = "a.txt",
        file2 = "b.txt",
        args = ["--width", "40"],
    )
    ```

    ```bash
    bazel run //:compare
    ```

    Alternatively, pass in the file arguments via `args`.

    ```starlark
    sdiff_binary(
        name = "compare",
        args = ["$(rootpath a.txt)", "$(rootpath b.txt)"],
        data = ["a.txt", "b.txt"],
    )
    ```

    Args:
        name: The name of the rule
        file1: First file to compare
        file2: Second file to compare
        **kwargs: Additional arguments to pass to the underlying binary rule.
    """
    if file2 and not file1:
        fail("""\
Error: `file2` cannot be passed to sdiff_binary without also passing `file1`
""")
    if file1 and partial.is_instance(file1):
        target = name + ".1"
        partial.call(file1, name = target, out = target + ".in")
        file1 = target

    if file2 and partial.is_instance(file2):
        target = name + ".1"
        partial.call(file2, name = target, out = target + ".in")
        file2 = target

    _sdiff_binary(
        name = name,
        file1 = file1,
        file2 = file2,
        **kwargs
    )
