#!/usr/bin/env bash
#
# Shows an end-to-end workflow for running a build that applies diffs to the source files.
# If the build failed, then we retry after applying the diffs.
# This is meant to mimic the behavior of the `aspect build` command that will soon be extended
# by using the Aspect CLI.
#
# To make the build fail when a diff is present, run with `--fail-on-diff`.
# Run with `--dry-run` to just print the patches and not apply them.
set -o errexit -o pipefail -o nounset

if [ "$#" -eq 0 ]; then
	echo "usage: build.sh [target pattern...]"
	exit 1
fi

fix="patch"
buildevents=$(mktemp)
filter='.namedSetOfFiles | values | .files[] | select(.name | endswith($ext)) | ((.pathPrefix | join("/")) + "/" + .name)'

args=(
	"--build_event_json_file=$buildevents"
	"--remote_download_regex='.*\.patch'"
)

# This is a rudimentary flag parser.
if [ $1 == "--fail-on-diff" ]; then
	args+=(
		"--@diff.bzl//diff:validate_diffs"
		"--keep_going"
	)
	shift
else
	args+=(
		"--output_groups=diff_bzl__patch"
	)
fi

if [ $1 == "--dry-run" ]; then
	fix="print"
	shift
fi

# Build outputs including patches.
# TODO: if this build fails, maybe applying the patches will make it pass?
bazel build ${args[@]} $@

if [ -n "$fix" ]; then
	valid_patches=$(jq --arg ext .patch --raw-output "$filter" "$buildevents" | tr -d '\r')
	while IFS= read -r patch; do
		# Exclude coverage, and check if the patch is empty.
		if [[ "$patch" == *coverage.dat ]] || [[ ! -s "$patch" ]]; then
			# Patch is empty. No linting errors.
			continue
		fi

		case "$fix" in
		"print")
			echo "From ${patch}:"
			cat "${patch}"
			echo
			;;
		"patch")
			patch <${patch}
			;;
		*)
			echo >2 "ERROR: unknown fix type $fix"
			exit 1
			;;
		esac

	done <<<"$valid_patches"
fi
