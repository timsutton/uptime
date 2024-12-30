#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# Because we still use bazel in this staging script, we still invoke deps.sh because it will
# ensure that the PATH is updated to include the swift distribution's bin dirs.
# shellcheck source=deps.sh
source ./script/deps.sh

rm -rf "${STAGING_DIR}" && mkdir -p "${STAGING_DIR}"

# We assemble the output of a Bazel query into an array that holds all runnable executables.
# See the referenced starlark details for more of the logic in the actual query.
output_exes=()
while IFS= read -r bazel_built_exe; do
	output_exes+=("$bazel_built_exe")
done < <(bazel cquery --output=starlark --starlark:file=script/util/runnable_exes.star //src/... | awk NF)
echo "${output_exes[@]}"

# Copy all these exes into the staging directory
for exe in "${output_exes[@]}"; do
	intermediate_path=$(dirname "$exe")
	mkdir -p "$STAGING_DIR/$intermediate_path"
	cp "$exe" "$STAGING_DIR/$intermediate_path/"
done
