# validate_override

This e2e tests that the `validate` attribute in `diff` and other rules overrides behaviour set by the bool flag --@diff.bzl//diff:validate.

The flag is explicitly set to true in [.bazelrc](./.bazelrc) while `validate = 0` is passed into the macros.
