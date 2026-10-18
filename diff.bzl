"Re-export for syntax sugar load"

load("//diff:cmp.bzl", _cmp = "cmp")
load("//diff:diff.bzl", _diff = "diff")
load("//diff:diff3.bzl", _diff3 = "diff3")
load("//diff:sdiff.bzl", _sdiff = "sdiff")
load("//diff:sync_source_file.bzl", _sync_source_file = "sync_source_file")

cmp = _cmp
diff = _diff
diff3 = _diff3
sdiff = _sdiff
sync_source_file = _sync_source_file
