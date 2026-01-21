# Bazel rules for GNU diffutils

A native rust port of GNU [diffutils](https://crates.io/crates/diffutils) provides `diff` and `cmp` (`sdiff` and `diff3` not yet supported).

This project provides rules that run these programs as Bazel "actions".

## Installation

Follow instructions from the release you wish to use:
<https://github.com/kormide/diff.bzl/releases>

## Design:

1. We strictly provide support for diffutils binaries published by [uutils/diffutils](https://github.com/uutils/diffutils).
1. Default toolchain registration will be that pre-built binary.
1. We support the same Bazel versions as bazel-lib 3.x since the diff outputs can be useful for the diff_test or write_source_files

Undecided:

1. Should we also have some testing rule here, or is that only in the bazel-lib layer?
1. We should have a validation action so it's possible to mark a diff target as "I expect no diff" - how will this work?
1. How do users simply "accept" the diffs by running patch - probably an Aspect CLI AXL file in this repo that provides a command.
