#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [[ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
   echo "Expected the BUILD_WORKSPACE_DIRECTORY environment variable to be set" >&2
   exit 2
fi

patch_path=$(realpath "{{PATCH_FILE}}")
if [ "$(head -c 1 "${patch_path}")" == "" ]; then
        echo "Already up to date" >&2
    exit 0
fi

cd "${BUILD_WORKSPACE_DIRECTORY}"

patch {{PATCH_ARGS}} < "${patch_path}"
