#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [[ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
   echo "Expected BUILD_WORKSPACE_DIRECTORY env var to exist" >&2
   exit 2
fi

patch_path=$(realpath "{{PATCH_FILE}}")
cd "${BUILD_WORKSPACE_DIRECTORY}"

{{PATCH_CMD}} < "${patch_path}"

echo "hello!"
