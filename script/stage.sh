#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

lang="${1}"
if [ "${platform}" = "linux" ] && [ "${lang}" = "swift" ]; then
continue
fi

mkdir -p "artifacts/${platform}/${lang}"
src_path=$(bazel cquery --ui_event_filters=-info --output=starlark --starlark:expr=target.files_to_run.executable.path //src/${lang}/...)
cp -v "${src_path}" "artifacts/${platform}/${lang}"
