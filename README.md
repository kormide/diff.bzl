# Bazel rules for GNU diffutils

[GNU diffutils](https://www.gnu.org/software/diffutils/) provides `diff`, `cmp`, `diff3`, and `sdiff`.

This project provides rules that run these programs as Bazel actions.

By default, the project registers toolchains for [prebuilt binaries](https://github.com/kormide/diffutils-prebuilt) as diffutils only does source releases. You may alternatively register your own toolchain based on a source build of the diffutils BCR entry (see [example](./e2e/diffutils_from_source)).

## Documentation

To install, follow instructions from the [release](https://github.com/kormide/diff.bzl/releases) you wish to use.

See the [docs](./docs) folder for rule documentation.

## Examples

### Create a patch from the diff between two files

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

Pass `validate = 1` to `diff` to create a build validation error when a generated source input diverges from the output tree file. This is an alternative to a [write_source_files](https://registry.bazel.build/docs/bazel_lib/3.2.2#lib-write_source_files-bzl) flow, but fails the build rather than a test.

```starlark
load("@diff.bzl//diff:defs.bzl", "diff")

diff(
    name = "foo"
    args = ["--unified"],
    file1 = "foo.pb.go",
    file2 = ":foo_generated",
    validate = 1
)
```

A build error message with command to run to patch the file will be output.

```
ERROR: diff command exited with non-zero status.

To accept the diff, run:
(cd $(bazel info workspace); patch -p0 < bazel-out/k8-fastbuild/bin/foo.patch)
```

To validate all `diff`, `cmp`, etc. actions by default, set `common --@diff.bzl//diff:validate=true` in your bazelrc.

### Compare binary files

```starlark
load("@diff.bzl//diff:defs.bzl", "cmp")

cmp(
    name = "compare_bins"
    args = ["--verbose"],
    file1 = "a",
    file2 = "b",
    out = "compare.out"
)
```

compare.out

```
1 125  10
2 142  77
3  46 171
4  41 312
5  62 134
6 315 353
7 231 360
8 231 167
```
