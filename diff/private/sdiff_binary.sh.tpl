#!/usr/bin/env bash

set -o errexit -o pipefail -o nounset

exec {sdiff} {file1} {file2} "$@"
