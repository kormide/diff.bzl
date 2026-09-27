#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [[ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
   echo "Expected BUILD_WORKSPACE_DIRECTORY env var to exist" >&2
   exit 2
fi

src_path=$(realpath "{{SRC}}")
cd "${BUILD_WORKSPACE_DIRECTORY}"

cp "${src_path}" "{{DST}}"

echo "hello!"

