#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

rm -rf "${STAGING_DIR}"

# List of langs which should produce static, relocatable binaries
# which we can stage and test on a different worker
for lang in c go kt rs swift zig; do
  mkdir -p "${STAGING_DIR}/${PLATFORM}/${lang}"

  # Run this query to just get the runnable executable path
  #
  # We squelch progress output and even errors, because other lib type targets
  # have no executable path which could get returned by `target.files_to_run.executable.path`
  #
  # TODO: instead of doing //src/${lang} loop, we should just take the same target list from our original build query in build.sh
  # also TODO: doing the above could probably allow us to remove the -error/info ui_event_filter because we wouldn't
  # be including other targets under ...

  output_exe_path=$(bazel cquery \
    --noshow_progress \
    --ui_event_filters=-info,-error \
    --output=starlark \
    --starlark:expr='target.files_to_run.executable.path if target.files_to_run.executable.path.endswith("uptime") else ""' \
    //src/${lang}/... |
    xargs)

  cp -v "${output_exe_path}" "${STAGING_DIR}/${PLATFORM}/${lang}"
done
