"Public diff.bzl API re-exports"

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:cmp.bzl", "cmp_rule")
load("//diff/private:diff.bzl", "diff_rule")

def cmp(name, file1, file2, args = [], out = None, **kwargs):
    """Runs cmp (binary diff) between two files and returns the output.

    Args:
        name: The name of the rule.
        file1: The first file to cmp.
        file2: The second file to cmp.
        args: Additional arguments to pass to cmp.
        out: The output file to write the output of cmp to. Defaults to ${name}.out.
        **kwargs: Additional arguments to pass to the underlying cmp_rule.
    """
    if file1 and partial.is_instance(file1):
        file1_target = name + ".file1"
        partial.call(file1, name = file1_target, out = file1_target + ".in")
        file1 = file1_target

    if file2 and partial.is_instance(file2):
        file2_target = name + ".file2"
        partial.call(file2, name = file2_target, out = file2_target + ".in")
        file2 = file2_target

    cmp_rule(
        name = name,
        args = args,
        file1 = file1,
        file2 = file2,
        out = out or name + ".out",
        **kwargs
    )

def diff(name, file1, file2, args = ["--unified"], patch = None, **kwargs):
    """Runs a diff between two files and returns a patch.

    Args:
        name: The name of the rule.
        file1: The first file to diff.
        file2: The second file to diff.
        args: Additional arguments to pass to diff.
        patch: The output file to write the diff to. Defaults to ${name}.patch.
        **kwargs: Additional arguments to pass to the underlying diff_rule.
    """
    if file1 and partial.is_instance(file1):
        file1_target = name + ".file1"
        partial.call(file1, name = file1_target, out = file1_target + ".in")
        file1 = file1_target

    if file2 and partial.is_instance(file2):
        file2_target = name + ".file2"
        partial.call(file2, name = file2_target, out = file2_target + ".in")
        file2 = file2_target

    diff_rule(
        name = name,
        args = args,
        file1 = file1,
        file2 = file2,
        patch = patch or name + ".patch",
        **kwargs
    )
