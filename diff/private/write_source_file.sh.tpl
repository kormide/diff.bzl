#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [[ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
   echo "Expected BUILD_WORKSPACE_DIRECTORY env var to be set" >&2
   exit 2
fi

src_path=$(realpath "{{SRC}}")
cd "${BUILD_WORKSPACE_DIRECTORY}"

echo "Writing source file"
echo "From: {{SRC}}"
echo "To: {{DST}}"

mkdir -p "$(dirname "{{DST}}")"

# Create the file with default and without the executable bit,
# instead of inheriting these from the Bazel output tree.
if [[ -f "${src_path}" ]]; then
    touch "{{DST}}"
fi

cp -r "${src_path}" "{{DST}}"
