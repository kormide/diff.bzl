#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [[ -z "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
   echo "Expected BUILD_WORKSPACE_DIRECTORY env var to be set" >&2
   exit 2
fi

srcs=( {{SRCS}} )
dsts=( {{DSTS}} )

if (( ${#srcs[@]} != ${#dsts[@]} )); then
   echo "The number of sources (${#srcs[@]}) differs from the number of destinations (${#dsts[@]})" >&2
   exit 2
fi

for i in "${!srcs[@]}"; do
    srcs[$i]="$(realpath "${srcs[$i]}")"
done

cd "${BUILD_WORKSPACE_DIRECTORY}"

echo "Writing ${#srcs[@]} source file(s)"

for i in "${!srcs[@]}"; do
    src="${srcs[$i]}"
    dst="${dsts[$i]}"

    echo "Copying ${src} to ${dst}"
    mkdir -p "$(dirname "${dst}")"

    # Create the file with default and without the executable bit,
    # instead of inheriting these from the Bazel output tree.
    if [[ -f "${src}" ]]; then
        touch "{{dst}}"
    fi

    cp -r "${src}" "${dst}"
done
