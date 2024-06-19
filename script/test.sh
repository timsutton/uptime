#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# For whatever reason, the archive tar process doesn't preserve executability on the mode
# TODO: re-check this assumption, this seems like would be very wrong
chmod -R a+x "${STAGING_DIR}"

find "${STAGING_DIR}" -type f -name uptime -print -exec {} \;
