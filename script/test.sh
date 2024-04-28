#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# For whatever reason, the archive tar process doesn't preserve executability on the mode
chmod -R a+x artifacts

find . -type f -name uptime -print -exec {} \;
