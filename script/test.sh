#!/bin/bash

set -euo pipefail
set -x

platform="macos"
if [[ "$(uname -s)" == "Linux" ]]; then
  export platform="linux"
fi

# For whatever reason, the archive tar process doesn't preserve executability on the mode
chmod -R a+x artifacts

"./artifacts/${platform}/c/uptime"
"./artifacts/${platform}/go/uptime"

# if [[ "${platform}" == "macos" ]]; then
#   "./artifacts/macos/rs/uptime"
#   "./artifacts/macos/swift/uptime"
# fi
