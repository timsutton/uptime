#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# TODO: deps.sh is only here effectively for installing the swift runtime (until we can implement static linking on Linux)
#       but really, we should export only the swift runtime install function out of common.sh or something, and call it here.
# shellcheck source=deps.sh
source ./script/deps.sh

# For whatever reason, the archive tar process doesn't preserve executability on the mode
# TODO: re-check this assumption, this seems like would be very wrong
chmod -R a+x "${STAGING_DIR}"

# We don't use `find -exec` here because we want the script to error immediately if any of them fail
for bin in $(find "${STAGING_DIR}" -type f -name uptime); do $bin; done
