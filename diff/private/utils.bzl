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
