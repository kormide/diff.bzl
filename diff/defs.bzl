"Public API re-exports"

# TODO: validation action that diff --version contains GNU

load("@bazel_skylib//lib:partial.bzl", "partial")
load("//diff/private:diff.bzl", "diff_rule")

def diff(name, file1, file2, **kwargs):
    """Runs a diff between two files and returns the exit code.

    Args:
        name: The name of the rule.
        file1: The first file to diff.
        file2: The second file to diff.
        **kwargs: Additional arguments to pass to the diff rule.
    """
    if file1 and partial.is_instance(file1):
        file1_target = name + ".file1"
        partial.call(file1, name = file1_target, out = file1_target + ".in")
        file1 = file1_target

    if file2 and partial.is_instance(file2):
        file2_target = name + ".file2"
        partial.call(file2, name = file2_target, out = file2_target + ".in")
        file2 = file2_target

    diff_rule(name = name, file1 = file1, file2 = file2, **kwargs)
