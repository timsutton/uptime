#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

if [[ "${platform}" == "macos" ]]; then
  command -v bazelisk >/dev/null || brew install bazelisk
fi
