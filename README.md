> [!WARNING]
> This ruleset is under active development. The API is subject to breaking changes before a v1 release.

# Bazel rules for GNU diffutils

[GNU diffutils](https://www.gnu.org/software/diffutils/) provides `diff`, `cmp`, `diff3`, and `sdiff`.

This project provides rules that run these programs as Bazel actions.

By default, the project registers toolchains for [prebuilt binaries](https://github.com/kormide/diffutils-prebuilt) as diffutils only does source releases. You may alternatively register your own toolchain based on a source build of the diffutils BCR entry (see [example](./e2e/diffutils_from_source)).

## Documentation

To install, follow instructions from the [release](https://github.com/kormide/diff.bzl/releases) you wish to use.

See the [docs](./docs) folder for rule documentation and examples.

## Use cases

### Create different types of patches

```starlark
load("@diff.bzl//diff:defs.bzl", "diff")

diff(
    name = "patch"
    args = ["--unified"],
    file1 = "a.txt",
    file2 = "b.txt",
    patch = "a.patch"
)
```

### Keep generated source files up to date

See [Patching source files](./docs/patching_source_files.md).

### Support automatic patch workflows for CI

This ruleset outputs patches into a distinct `diff_bzl__patch` output group making it easier for patches to be collected and then applied using automation. See the [build & patch](./examples/build-and-patch.sh) example script.
