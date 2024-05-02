#!/bin/bash

set -euo pipefail

set -x

platform="macos"
if [ "$(uname -s)" = "Linux" ]; then
  export platform="linux"
fi

# hack
bazel build --compilation_mode=opt //src/kt:uptime

# List of langs which should produce static, relocatable binaries
# which we can stage and test on a different worker
for lang in c go kt rs swift zig; do
  mkdir -p "artifacts/${platform}/${lang}"

  # Run this query to just get the runnable executable path
  # we squelch progress output and even errors, because other lib type targets
  # have no executable path which could get returned by `target.files_to_run.executable.path`
  #
  # We also grep for an output exe that exactly matches 'uptime', because at least the kt
  # target can have multiple executables.
  src_path=$(bazel cquery \
    --noshow_progress \
    --ui_event_filters=-info,-error \
    --output=starlark \
    --starlark:expr=target.files_to_run.executable.path \
    //src/${lang}/... |
    grep -e '^.*uptime$')

  cp -v "${src_path}" "artifacts/${platform}/${lang}"
done
