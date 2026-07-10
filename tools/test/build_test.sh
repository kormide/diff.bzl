#!/usr/bin/env bash

# Test entrypoint for build_test. Bazel builds data dependencies before this
# script runs; on success we emit JUnit XML to $XML_OUTPUT_FILE.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${TEST_TMPDIR:-${TMPDIR:-/tmp}}/test.log"
touch "$LOG"

START=$SECONDS
EXIT_CODE=0
DURATION=$((SECONDS - START))

if [[ -n "${XML_OUTPUT_FILE:-}" ]]; then
  "${SCRIPT_DIR}/emit-test-xml.sh" "$LOG" "$XML_OUTPUT_FILE" "$DURATION" "$EXIT_CODE"
fi

exit "$EXIT_CODE"
