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

def source_files_info(source_labels):
    source_file_names = [source_label.name for source_label in source_labels]
    all = native.glob(source_file_names, allow_empty = True, exclude_directories = 0)
    files_only = native.glob(source_file_names, allow_empty = True)

    exists = [source_file_name in all for source_file_name in source_file_names]
    is_directory = [exists[i] and not (source_file_name in files_only) for i, source_file_name in enumerate(source_file_names)]

    return (exists, is_directory)

def label_to_safe_target_name(label):
    return str(label).replace("@", "_").replace("/", "_").replace(":", "_")
