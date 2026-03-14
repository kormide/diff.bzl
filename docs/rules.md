<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public diff.bzl API re-exports

<a id="cmp"></a>

## cmp

<pre>
load("@diff.bzl//diff:defs.bzl", "cmp")

cmp(<a href="#cmp-name">name</a>, <a href="#cmp-srcs">srcs</a>, <a href="#cmp-args">args</a>, <a href="#cmp-out">out</a>, <a href="#cmp-kwargs">**kwargs</a>)
</pre>

Runs cmp (binary diff) between two files and returns the output.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="cmp-name"></a>name |  The name of the rule   |  none |
| <a id="cmp-srcs"></a>srcs |  The files to compare.   |  none |
| <a id="cmp-args"></a>args |  Additional arguments to pass to cmp   |  `[]` |
| <a id="cmp-out"></a>out |  The output file to write the output of cmp to. Defaults to ${name}.out.   |  `None` |
| <a id="cmp-kwargs"></a>kwargs |  Additional arguments to pass to the underlying rule.   |  none |


<a id="diff"></a>

## diff

<pre>
load("@diff.bzl//diff:defs.bzl", "diff")

diff(<a href="#diff-name">name</a>, <a href="#diff-srcs">srcs</a>, <a href="#diff-args">args</a>, <a href="#diff-patch">patch</a>, <a href="#diff-kwargs">**kwargs</a>)
</pre>

Runs a diff between files and return a patch.

Examples:

Create a patch between two files.

```starlark
diff(
    name = "patch"
    srcs = ["a.txt", "b.txt"],
    patch = "a.patch"
)
```

Use `--from-file` to create a patch from one file to several files.

```starlark
diff(
    name = "patch"
    args = ["--unified", "--from-file", "$(execpath a.txt)"],
    srcs = ["a.txt", "b.txt", "c.txt"],
    patch = "a.patch"
)
```

_By default, diff creates a unified format patch by passing `["--unified"]`
to `args`. If overriding arguments, --unified must be added explicitly._


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="diff-name"></a>name |  The name of the rule   |  none |
| <a id="diff-srcs"></a>srcs |  The files to compare.   |  none |
| <a id="diff-args"></a>args |  Additional arguments to pass to diff   |  `["--unified"]` |
| <a id="diff-patch"></a>patch |  The output file to write the diff to. Defaults to ${name}.patch.   |  `None` |
| <a id="diff-kwargs"></a>kwargs |  Additional arguments to pass to the underlying rule   |  none |


