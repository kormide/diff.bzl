<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="diff"></a>

## diff

<pre>
load("@diff.bzl//diff:defs.bzl", "diff")

diff(<a href="#diff-name">name</a>, <a href="#diff-file1">file1</a>, <a href="#diff-file2">file2</a>, <a href="#diff-patch">patch</a>, <a href="#diff-exit_code">exit_code</a>, <a href="#diff-kwargs">**kwargs</a>)
</pre>

Runs a diff between two files and returns the exit code.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="diff-name"></a>name |  The name of the rule.   |  none |
| <a id="diff-file1"></a>file1 |  The first file to diff.   |  none |
| <a id="diff-file2"></a>file2 |  The second file to diff.   |  none |
| <a id="diff-patch"></a>patch |  The output file to write the diff to. Defaults to <name>.patch.   |  `None` |
| <a id="diff-exit_code"></a>exit_code |  The output file to write the exit code to. Defaults to <name>.exit_code.   |  `None` |
| <a id="diff-kwargs"></a>kwargs |  Additional arguments to pass to the diff_rule.   |  none |


