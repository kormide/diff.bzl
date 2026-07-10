#!/usr/bin/env bash

# Asserts that a file is empty (validation success for diff/cmp rules).
# Captures validation output and emits JUnit XML to $XML_OUTPUT_FILE when set.

set -euo pipefail

INPUT_FILE="$1"
VALID_FILE="$2"
EMIT_TEST_XML="$3"

LOG="${TMPDIR:-/tmp}/validate-$$.log"
touch "$LOG"

touch "$VALID_FILE"
EXIT_CODE=0
if [ "$(head -c 1 "$INPUT_FILE")" != "" ]; then
    printf '%s\n' "$ERROR_MESSAGE" >&2 | tee "$LOG"
    EXIT_CODE=1
fi

if [[ -n "${XML_OUTPUT_FILE:-}" ]]; then
    START=$SECONDS
    DURATION=$((SECONDS - START))
    "$EMIT_TEST_XML" "$LOG" "$XML_OUTPUT_FILE" "$DURATION" "$EXIT_CODE"
fi

exit "$EXIT_CODE"
