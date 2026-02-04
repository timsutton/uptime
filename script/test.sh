#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# For whatever reason, the archive tar process doesn't preserve executability on the mode,
# so we must mark things as executable.
chmod -R a+x "${STAGING_DIR}"

# We don't use `find -exec` here because we want the script to error immediately if any of them fail
# shellcheck disable=SC2044
for bin in $(find "${STAGING_DIR}" -type f \( -name uptime -o -name uptime_aot \)); do
	echo "Executing ${bin}"
	$bin
	echo ""
done
