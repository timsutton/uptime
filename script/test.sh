#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

function execute_built_binaries() {
    # For whatever reason, the archive tar process doesn't preserve executability on the mode
    chmod -R a+x "${STAGING_DIR}"
    find "${STAGING_DIR}" -type f -name uptime -print -exec {} \;
}

# At this point these are only lint-type checks
function run_bazel_tests() {
    bazel test --test_output=errors //...
}

execute_built_binaries
run_bazel_tests
