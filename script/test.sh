#!/bin/bash

set -euo pipefail

platform="macos"
if [[ "$(uname -s)" == "Linux" ]]; then
  export platform="linux"
fi

# For whatever reason, the archive tar process doesn't preserve executability on the mode
chmod -R a+x artifacts

find . -type f -name uptime -print -exec {} \;
