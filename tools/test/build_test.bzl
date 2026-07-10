"""A test verifying other targets build as part of a `bazel test`.

Like @bazel_skylib//rules:build_test, but the test runner writes JUnit XML to
$XML_OUTPUT_FILE so tests work under Bazel 9 (bazelbuild/bazel#28111).
"""

load("@bazel_skylib//lib:new_sets.bzl", "sets")

def _build_test_impl(ctx):
    is_windows = ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo])
    if is_windows:
        fail("build_test with XML output is not supported on Windows")

    emit_xml_link = ctx.actions.declare_file(ctx.label.name + ".emit-test-xml.sh")
    ctx.actions.symlink(
        output = emit_xml_link,
        target_file = ctx.file._emit_test_xml,
        is_executable = True,
    )

    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output = executable,
        is_executable = True,
        content = """#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${{BASH_SOURCE[0]}}")" && pwd)"
LOG="${{TEST_TMPDIR:-${{TMPDIR:-/tmp}}}}/test.log"
touch "$LOG"

START=$SECONDS
EXIT_CODE=0
DURATION=$((SECONDS - START))

if [[ -n "${{XML_OUTPUT_FILE:-}}" ]]; then
  "${{SCRIPT_DIR}}/{emit_xml_name}" "$LOG" "$XML_OUTPUT_FILE" "$DURATION" "$EXIT_CODE"
fi

exit "$EXIT_CODE"
""".format(emit_xml_name = emit_xml_link.basename),
    )

    return [DefaultInfo(
        executable = executable,
        runfiles = ctx.runfiles(
            files = ctx.files.data + [emit_xml_link],
        ),
    )]

_build_test = rule(
    implementation = _build_test_impl,
    attrs = {
        "data": attr.label_list(allow_files = True),
        "_emit_test_xml": attr.label(
            default = "//tools/test:emit-test-xml.sh",
            allow_single_file = True,
        ),
        "_windows_constraint": attr.label(default = "@platforms//os:windows"),
    },
    test = True,
)

_GENRULE_ATTRS = [
    "compatible_with",
    "exec_compatible_with",
    "restricted_to",
    "tags",
    "target_compatible_with",
]

def build_test(name, targets, **kwargs):
    """Test rule checking that other targets build.

    This works not by an instance of this test failing, but instead by
    the targets it depends on failing to build, and hence failing
    the attempt to run this test.

    Typical usage:

    ```
      load("@diff.bzl//tools/test:build_test.bzl", "build_test")
      build_test(
          name = "my_build_test",
          targets = [
              "//some/package:rule",
          ],
      )
    ```

    Args:
      name: The name of the test rule.
      targets: A list of targets to ensure build.
      **kwargs: The [common attributes for tests](https://bazel.build/reference/be/common-definitions#common-attributes-tests).
    """
    if len(targets) == 0:
        fail("targets must be non-empty", "targets")
    if kwargs.get("data", None):
        fail("data is not supported on a build_test()", "data")

    # Remove any duplicate test targets.
    targets = sets.to_list(sets.make(targets))

    # Use a genrule to ensure the targets are built (works because it forces
    # the outputs of the other rules on as data for the genrule)

    # Split into batches to hopefully avoid things becoming so large they are
    # too much for a remote execution set up.
    batch_size = max(1, len(targets) // 100)

    # Pull a few args over from the test to the genrule.
    genrule_args = {k: kwargs.get(k) for k in _GENRULE_ATTRS if k in kwargs}

    # Only the test target should be used to determine whether or not the deps
    # are built. Tagging the genrule targets as manual accomplishes this by
    # preventing them from being picked up by recursive build patterns (`//...`).
    genrule_tags = genrule_args.pop("tags", [])
    if "manual" not in genrule_tags:
        genrule_tags = genrule_tags + ["manual"]

    # Pass an output from the genrules as data to a shell test to bundle
    # it all up in a test.
    test_data = []

    for idx, batch in enumerate([targets[i:i + batch_size] for i in range(0, len(targets), batch_size)]):
        full_name = "{name}_{idx}__deps".format(name = name, idx = idx)
        test_data.append(full_name)
        native.genrule(
            name = full_name,
            srcs = batch,
            outs = [full_name + ".out"],
            testonly = 1,
            visibility = ["//visibility:private"],
            cmd = "touch $@",
            cmd_bat = "type nul > $@",
            tags = genrule_tags,
            **genrule_args
        )

    _build_test(
        name = name,
        data = test_data,
        size = kwargs.pop("size", "small"),  # Default to small for test size
        **kwargs
    )
