#!/bin/bash

set -euo pipefail
STAGING_DIR="artifacts"
platform="macos"
if [[ "$(uname -s)" == "Linux" ]]; then
  export platform="linux"
fi

# For whatever reason, the archive tar process doesn't preserve executability on the mode
chmod -R a+x "${STAGING_DIR}"

find "${STAGING_DIR}" -type f -name uptime -print -exec {} \;
