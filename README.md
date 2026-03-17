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
    srcs = ["a.txt", "b.txt"],
    patch = "a.patch"
)
```

### Keep generated sources up to date

Pass `validate = 1` to `diff` to create a build validation error when a generated source input diverges from the output tree file.

```starlark
load("@diff.bzl//diff:defs.bzl", "diff")

diff(
    name = "foo",
    srcs = [
      "foo.pb.go",
      ":foo_generated",
    ],
    validate = 1
)
```

A build error message with command to run to patch the file will be output.

```
ERROR: diff command exited with non-zero status.

To accept the diff, run:
(cd $(bazel info workspace); patch -p0 < bazel-out/k8-fastbuild/bin/foo.patch)
```

This also works for directories.

To validate all `diff`, `cmp`, etc. actions by default, set `common --@diff.bzl//diff:validate=true` in your bazelrc.

### Support automatic patch workflows for CI

This ruleset outputs patches into a distinct `diff_bzl__patch` output group making it easier for patches to be collected and then applied using automation. See the [build & patch](./examples/build-and-patch.sh) example script.
