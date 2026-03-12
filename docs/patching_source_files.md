# Patching source files

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

To validate all `diff`, `cmp`, etc. actions by default, set `common --@diff.bzl//diff:validate=true` in your bazelrc.
