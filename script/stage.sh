#!/bin/bash

set -euo pipefail

platform="macos"
if [[ "$(uname -s)" == "Linux" ]]; then
  export platform="linux"
fi

# add rs and swift once those are working on Linux
for lang in c go; do
    mkdir -p "artifacts/${platform}/${lang}"
    src_path=$(bazel cquery --ui_event_filters=-info --output=starlark --starlark:expr=target.files_to_run.executable.path //src/${lang}/...)
    cp -v "${src_path}" "artifacts/${platform}/${lang}"
    chmod -R a+x "artifacts/${platform}/${lang}"
done
