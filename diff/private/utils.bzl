"""Utility functions"""

def source_file_info(source_label):
    """Determine whether a file exists in the source tree and is a directory

    Args:
        source_label: Label of source file within the current package

    Returns:
        A boolean pair tuple (exists, is_directory) indicating the file's existence
        and whether it's a directory

    """
    all = native.glob([source_label.name], allow_empty = True, exclude_directories = 0)
    files_only = native.glob([source_label.name], allow_empty = True)

    exists = len(all) > 0
    is_directory = exists and not files_only

    return (exists, is_directory)

def readable_path(file):
    """Path to `file` as read from the workspace root.

    A source file is already workspace-relative. A generated file's path is
    relative to the execution root, so a command that cd's to the workspace can
    only read it back if a `bazel-out` convenience symlink happens to exist
    there. Workspaces built with `--experimental_convenience_symlinks=ignore`
    have no such symlink, so resolve the execution root explicitly instead.

    Args:
        file: Source or generated File to read.

    Returns:
        A workspace-relative source path or an execution-root-based generated path,
        with command substitution escaped for the validation action.
    """
    if file.is_source:
        return file.path
    return "\\$(bazel info execution_root)/{}".format(file.path)
