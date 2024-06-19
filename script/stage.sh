#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

rm -rf "${STAGING_DIR}"

# List of langs which should produce static, relocatable binaries
# which we can stage and test on a different worker
mkdir -p "${STAGING_DIR}"

# Run this query to just get the runnable executable path
#
# We squelch progress output and even errors, because other lib type targets
# have no executable path which could get returned by `target.files_to_run.executable.path`
#
# TODO: instead of doing //src/${lang} loop, we should just take the same target list from our original build query in build.sh
# also TODO: doing the above could probably allow us to remove the -error/info ui_event_filter because we wouldn't
# be including other targets under ...

output_exes=()

bazel cquery --output=starlark --starlark:file=script/util/runnable_exes.star //src/... |
  awk NF |
  while IFS= read -r line; do
    output_exes+=("$line")
  done

for exe in "${output_exes[@]}"; do
  intermediate_path=$(dirname "$exe")
  mkdir -p "$STAGING_DIR/$intermediate_path"
  cp "$exe" "$STAGING_DIR/$intermediate_path/"
done
