# Go Protocol Buffer Code Generation Example

This example demonstrates how to use `diff.bzl` to validate that generated Protocol Buffer code stays in sync with the source `.proto` definitions.

## Overview

This example shows a workflow for managing Go code generated from Protocol Buffer definitions:

1. **Proto Definition** (`foo.proto`) - Defines a simple `Foo` message with fields like name, description, age, and tags
2. **Build Configuration** (`BUILD`) - Uses Bazel rules to:
   - Compile the proto definition
   - Generate Go code from the proto
   - Use a `diff` rule to compare generated code against a checked-in reference
   - Include the result of the diff as an input to tests that validate the generated code is up-to-date
3. **Test** (`foo_test.go`) - Demonstrates usage of the generated protobuf message
4. **Utilities** (`build.sh`, `test.sh`) - Scripts to demonstrate the code generation workflow

## Primary Use Case: Catch Out-of-Sync Generated Code

This example demonstrates the primary motivation for `diff.bzl`: **detecting when generated code doesn't match the source definition**.

### Scenario

A developer modifies `foo.proto` to remove or change a field. However:

1. They forget to regenerate `foo.pb.go`, OR
2. They regenerate it but incorrectly (e.g., an AI agent makes mistakes)

The Go code that uses the proto may still compile and pass editor checks, but the test will immediately fail:

```
bazel test //examples/go_proto_library:foo_usage_test

ERROR: /path/to/examples/BUILD:23:5: Action examples/go_codegen_diff.exit_code.valid failed: (Exit 1): bash failed: error executing Action command
        ERROR: diff command exited with non-zero status.

        To accept the diff, run:
        patch -d $(bazel info workspace) -p0 < $(bazel info bazel-bin)/examples/go_codegen_diff.patch
```

### The Fix

The error message provides the exact command to apply the auto-generated patch:

```bash
patch -d $(bazel info workspace) -p0 < $(bazel info bazel-bin)/examples/go_codegen_diff.patch
```

After applying it, the test passes:

```bash
bazel test //examples/go_proto_library:foo_usage_test
INFO: Build completed successfully
//examples/go_proto_library:foo_usage_test PASSED
```

This ensures that even if developers or automated tools make mistakes, the build catches the inconsistency and provides an easy recovery path.

## Workflow

1. **Modify `foo.proto`** - Change the proto definition
2. **Run tests** - Bazel regenerates the Go code and compares it
3. **Review diff** - If there's a mismatch, check `bazel build :go_codegen_diff` to review changes
4. **Accept or reject** - Use the provided patch command or manually update `foo.pb.go`

## Additional Use Cases

- **Code Review** - Ensure proto changes are reviewed before code generation
- **CI/CD Validation** - Fail builds in CI when generated code is out of sync
- **Reproducibility** - Maintain a checked-in copy of generated code for version control
- **Debugging** - Review exactly what changed in generated code

See the main [README.md](../../README.md) for more information about `diff.bzl`.
