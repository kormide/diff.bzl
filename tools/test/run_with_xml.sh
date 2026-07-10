#!/usr/bin/env bash

# Runs a command, captures stdout/stderr to a log file, and emits JUnit XML to
# $XML_OUTPUT_FILE before exiting with the command's exit code.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="${TEST_TMPDIR:-${TMPDIR:-/tmp}}/test.log"

START=$SECONDS
set +e
"$@" >"$LOG" 2>&1
EXIT_CODE=$?
set -e
DURATION=$((SECONDS - START))

if [[ -n "${XML_OUTPUT_FILE:-}" ]]; then
  "${SCRIPT_DIR}/emit-test-xml.sh" "$LOG" "$XML_OUTPUT_FILE" "$DURATION" "$EXIT_CODE"
fi

exit "$EXIT_CODE"
