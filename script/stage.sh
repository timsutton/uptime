#!/bin/bash

set -euo pipefail

platform="macos"
if [ "$(uname -s)" = "Linux" ]; then
  export platform="linux"
fi

for lang in c go rs swift; do
  if [ "${platform}" = "linux" ]; then
    # skip rs and swift on linux for now
    if [ "${lang}" = "rs" ] || [ "${lang}" = "swift" ]; then
      continue
    fi
  fi
  mkdir -p "artifacts/${platform}/${lang}"
  src_path=$(bazel cquery --ui_event_filters=-info --output=starlark --starlark:expr=target.files_to_run.executable.path //src/${lang}/...)
  cp -v "${src_path}" "artifacts/${platform}/${lang}"
done
