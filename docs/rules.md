<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public diff.bzl API re-exports

<a id="cmp"></a>

## cmp

<pre>
load("@diff.bzl//diff:defs.bzl", "cmp")

cmp(<a href="#cmp-name">name</a>, <a href="#cmp-srcs">srcs</a>, <a href="#cmp-args">args</a>, <a href="#cmp-out">out</a>, <a href="#cmp-kwargs">**kwargs</a>)
</pre>

Runs cmp (binary diff) between two files and returns the output.

Examples:

Compare two binaries.

```starlark
cmp(
    name = "compare_bins",
    args = ["--bytes", "4", "--verbose"],
    srcs = ["bin_a", "bin_b"],
    out = "cmp_output"
)
```

Run cmp in a genrule.

```starlark
genrule(
    name = "run_cmp",
    srcs = ["bin_a", "bin_b"],
    outs = ["cmp_output"],
    cmd = "$(CMP_BIN) --verbose $(execpath bin_a) $(execpath bin_b) > $@",
    toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
)
```


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

Run diff in a genrule.

```starlark
genrule(
    name = "run_diff",
    srcs = ["a.txt", "b.txt"],
    outs = ["a.patch"],
    cmd = "$(DIFF_BIN) --unified $(execpath a.txt) $(execpath b.txt) > $@",
    toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
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


<a id="diff3"></a>

## diff3

<pre>
load("@diff.bzl//diff:defs.bzl", "diff3")

diff3(<a href="#diff3-name">name</a>, <a href="#diff3-srcs">srcs</a>, <a href="#diff3-args">args</a>, <a href="#diff3-out">out</a>, <a href="#diff3-kwargs">**kwargs</a>)
</pre>

Compare three files line by line.

Examples:

Compare three files.

```starlark
diff3(
    name = "compare",
    srcs = ["my.txt", "old.txt", "your.txt"],
    out = "comparison"
)
```

Output the merged file.

```starlark
diff3(
    name = "compare",
    args = ["--merge"],
    srcs = ["my.txt", "old.txt", "your.txt"],
    out = "comparison"
)
```

Run diff3 in a genrule.

```starlark
genrule(
    name = "run_sdiff",
    srcs = ["my.txt", "old.txt", "your.txt"],
    outs = ["comparison"],
    cmd = "$(DIFF3_BIN) $(execpath my.txt) $(execpath old.txt) $(execpath your.txt) > $@",
    toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
)
```


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="diff3-name"></a>name |  The name of the rule   |  none |
| <a id="diff3-srcs"></a>srcs |  The three files to compare.   |  none |
| <a id="diff3-args"></a>args |  Additional arguments to pass to diff3.   |  `[]` |
| <a id="diff3-out"></a>out |  The file to write the diff3 output to to. Defaults to ${name}.out.   |  `None` |
| <a id="diff3-kwargs"></a>kwargs |  Additional arguments to pass to the underlying rule.   |  none |


<a id="sdiff"></a>

## sdiff

<pre>
load("@diff.bzl//diff:defs.bzl", "sdiff")

sdiff(<a href="#sdiff-name">name</a>, <a href="#sdiff-srcs">srcs</a>, <a href="#sdiff-args">args</a>, <a href="#sdiff-out">out</a>, <a href="#sdiff-kwargs">**kwargs</a>)
</pre>

Produce a side-by-side diff of two files.

    Examples:

    Compare two files.
g
    ```starlark
    sdiff(
        name = "side_by_side",
        srcs = ["a.txt", "b.txt"],
        out = "comparison.txt"
    )
    ```

    Run sdiff in a genrule.

    ```starlark
    genrule(
        name = "run_sdiff",
        srcs = ["a.txt", "b.txt"],
        outs = ["comparison"],
        cmd = "$(SDIFF_BIN) $(execpath a.txt) $(execpath b.txt) > $@",
        toolchains = ["@diff.bzl//diff/toolchain:execution_type"],
    )
    ```

    Args:
        name: The name of the rule
        srcs: The two files to compare.
        args: Additional arguments to pass to sdiff.
        out: The output file to write the side-by-side comparison to. Defaults to ${name}.out.
        **kwargs: Additional arguments to pass to the underlying rule.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="sdiff-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="sdiff-srcs"></a>srcs |  <p align="center"> - </p>   |  none |
| <a id="sdiff-args"></a>args |  <p align="center"> - </p>   |  `[]` |
| <a id="sdiff-out"></a>out |  <p align="center"> - </p>   |  `None` |
| <a id="sdiff-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


