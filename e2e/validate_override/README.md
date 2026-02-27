# validate_override

This e2e tests that the `validate` attribute in `diff` overrides behaviour set by the bool flag --@diff.bzl//diff:validate_diffs.

The flag is explicitly set to true in [.bazelrc](./.bazelrc) while `validate = 0` is passed into the diff macro.
