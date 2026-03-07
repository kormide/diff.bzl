<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public diff.bzl API re-exports

<a id="diff"></a>

## diff

<pre>
load("@diff.bzl//diff:defs.bzl", "diff")

diff(<a href="#diff-name">name</a>, <a href="#diff-file1">file1</a>, <a href="#diff-file2">file2</a>, <a href="#diff-args">args</a>, <a href="#diff-patch">patch</a>, <a href="#diff-kwargs">**kwargs</a>)
</pre>

Runs a diff between two files and returns a patch.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="diff-name"></a>name |  The name of the rule.   |  none |
| <a id="diff-file1"></a>file1 |  The first file to diff.   |  none |
| <a id="diff-file2"></a>file2 |  The second file to diff.   |  none |
| <a id="diff-args"></a>args |  Additional arguments to pass to diff.   |  `[]` |
| <a id="diff-patch"></a>patch |  The output file to write the diff to. Defaults to ${name}.patch.   |  `None` |
| <a id="diff-kwargs"></a>kwargs |  Additional arguments to pass to the underlying diff_rule.   |  none |


