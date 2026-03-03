#!/usr/bin/env bash
#
# Shows an end-to-end workflow for accepting new patches without failing the build.
set -o errexit -o pipefail -o nounset

if [ "$#" -eq 0 ]; then
	echo "usage: test.sh [target pattern...]"
	exit 1
fi

fix=""
buildevents=$(mktemp)
filter='.namedSetOfFiles | values | .files[] | select(.name | endswith($ext)) | ((.pathPrefix | join("/")) + "/" + .name)'

args=(
    "--keep_going"
    "--output_groups=diff_bzl__patch"
	"--build_event_json_file=$buildevents"
	"--remote_download_regex='.*\.patch'"
)

# Run build with validation disabled and output group for patches.
# This will present us with patches to apply
if ! bazel build ${args[@]} $@; then
    echo "Build failed, applying patches"
    to_apply_patches=$(jq --arg ext .patch --raw-output "$filter" "$buildevents" | tr -d '\r')
    wksp=$(bazel info workspace)
    for patch in $to_apply_patches; do
        # continue if patch file content is empty
        if [[ ! -s "${wksp}/${patch}" ]]; then
            continue
        fi
        echo "Applying patch ${patch}"
        patch -d ${wksp} -p0 <${wksp}/${patch}
    done
fi

exec bazel test $@
