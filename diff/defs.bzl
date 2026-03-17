"Public diff.bzl API re-exports"

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:cmp.bzl", "cmp_rule")
load("//diff/private:diff.bzl", "diff_rule")

def cmp(name, srcs, args = [], out = None, **kwargs):
    """Runs cmp (binary diff) between two files and returns the output.

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

    # Determine whether patchable inputs are all source directories.
    # Bazel rules cannot detect source directories. This information is
    # needed to produce the correct patch command.
    source_directories = False
    if len(srcs) == 2:  # TODO: support multiple directory inputs with --to-file
        all_sources = set(native.glob([srcs[0]], exclude_directories = 0, allow_empty = True))
        file_sources = set(native.glob([srcs[0]], exclude_directories = 1, allow_empty = True))
        source_directories = len(all_sources.difference(file_sources)) > 0

    diff_rule(
        name = name,
        args = args,
        srcs = srcs,
        patch = patch or name + ".patch",
        source_directories = source_directories,
        **kwargs
    )
