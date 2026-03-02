# Bazel rules for GNU diffutils

https://www.gnu.org/software/diffutils/ provides `diff`, `cmp`, `diff3`, and `sdiff`.

This project provides rules that run these programs as Bazel actions.

By default, the project registers toolchains for prebuilt binaries in https://github.com/kormide/diffutils-prebuilt as diffutils only does source releases. You may alternatively register your own toolchain based on a source build of the [BCR entry](https://github.com/bazelbuild/bazel-central-registry/tree/main/modules/diffutils).

## Installation

Follow instructions from the release you wish to use:
<https://github.com/kormide/diff.bzl/releases>
