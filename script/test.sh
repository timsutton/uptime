#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# We don't use `find -exec` here because we want the script to error immediately if any of them fail
# shellcheck disable=SC2044
for bin in $(find "${STAGING_DIR}" -type f -name uptime); do
	echo "Executing ${bin}"
	$bin
	echo ""
done
