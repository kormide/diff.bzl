> [!WARNING]
> This ruleset is under active development. The API is subject to breaking changes before a v1 release.

# Bazel rules for GNU diffutils

[GNU diffutils](https://www.gnu.org/software/diffutils/) provides `diff`, `cmp`, `diff3`, and `sdiff`.

This project provides:

1. Rules that run diffutils programs as Bazel actions.
1. Macros for keeping generated source files up to date.

By default, the project registers toolchains for [prebuilt binaries](https://github.com/kormide/diffutils-prebuilt) as diffutils only does source releases. You may alternatively register your own toolchain based on a source build of the diffutils BCR entry (see [example](./e2e/diffutils_from_source)).

## Documentation

To install, follow instructions from the [release](https://github.com/kormide/diff.bzl/releases) you wish to use.

See the [docs](./docs) folder for rule documentation and examples.

## Use cases

### Create different types of patches

```starlark
load("@diff.bzl", "diff")

diff(
    name = "patch"
    args = ["--unified"],
    srcs = ["a.txt", "b.txt"],
    patch = "a.patch"
)
```

### Compare binary files

```starlark
load("@diff.bzl", "cmp")

cmp(
    name = "compare_bins",
    args = ["--bytes", "4", "--verbose"],
    srcs = ["bin_a", "bin_b"],
    out = "cmp_output"
)
```

### Produce human-readable diffs

```starlark
# Side-by-side diff
load("@diff.bzl", "sdiff")

sdiff(
    name = "side_by_side",
    srcs = ["a.txt", "b.txt"],
    out = "compare"
)
```

```starlark
# Three way diff
load("@diff.bzl", "diff3")

sdiff(
    name = "three_way_diff",
    srcs = ["my.txt", "old.txt", "yours.txt"],
    out = "compare"
)
```

### Keep generated sources up to date

Use the `sync_source_file` macro to keep a generated file in the source tree in sync with its origin.

```starlark
load("@diff.bzl", "sync_source_file")

sync_source_file(
    name = "foo",
    out = "foo.txt",
    origin = ":generated_foo",
)
```

The macro creates a patch with `diff`, validates it, and creates two executable targets: one to preview the differences, and another to update the source tree file or directory to the desired state.

When the files differ, a message is output via a failed build validation action instructing how to run the targets.

```
Source file foo.txt is out of sync with its origin.

To preview the differences, run:

bazel run //:foo.preview

To update, run:

bazel run //:foo --norun_validations
```

By default, updates are done via the `patch` tool. Alternatively, the source copy can be overwritten by setting `mode = "copy"`.

The preview tool runs `sdiff` by default but can be overridden with `preview_target`.

To keep binary files in sync, use [sync_source_bin](./docs/rules.md#sync_source_bin).

### Support automated patch workflows

This ruleset outputs patches for source tree files into the `diff_bzl__patch` output group by default, making it easier to collect and apply patches in an automated fashion. See the [build & patch](./examples/build-and-patch.sh) example script.

The output groups for source patches can be customized via the `source_patch_output_groups` attribute. This can be used to categorize types of patches. For example, `diff` targets with `source_patch_output_groups = ["autopatch"]` might identify patches that should automatically be applied if the build fails on CI, whereas a `"snapshot_test"` group could identify patches that require human review, etc.

```starlark
diff(
    name = "foo",
    in_file = ":foo_generated",
    out_file = "foo.pb.go",
    source_patch_output_groups = ["autopatch"],
)
```

NB: Only patches for files in the source tree are placed in the above output group(s). Patches for files in the output tree are not included as they should not be modified outside of Bazel.
