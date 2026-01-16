# Bazel rules for GNU diffutils

https://www.gnu.org/software/diffutils/ provides `diff`, `cmp`, `diff3`, and `sdiff`.

This project provides rules that run these programs as Bazel "actions".

## Installation

Follow instructions from the release you wish to use:
<https://github.com/kormide/diff.bzl/releases>

## Design:

1. We strictly provide support for GNU diffutils binaries
1. That project should be published as a C module on the BCR, using just overlays and upstream sources
1. Users of diff.bzl can choose to register a from-source toolchain that builds that BCR entry
1. However most users will prefer a pre-built binary, we can follow the https://github.com/aspect-build/bsdtar-prebuilt recipe
1. Default toolchain registration will be that pre-built binary.
1. We support the same Bazel versions as bazel-lib 3.x since the diff outputs can be useful for the diff_test or write_source_files

Undecided:

1. Should we also have some testing rule here, or is that only in the bazel-lib layer?
1. We should have a validation action so it's possible to mark a diff target as "I expect no diff" - how will this work?
1. How do users simply "accept" the diffs by running patch - probably an Aspect CLI AXL file in this repo that provides a command.
