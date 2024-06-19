# shellcheck shell=bash
#
# Intended to be sourced by other scripts

# A query that will return all targets that produce a binary
# that we want to consider our artifact for testing.
#
# Note that kt is an exception, because we only test the native_image produced kt binary
export BINARIES_QUERY="
    kind(.*_binary, //src/... except //src/kt/...)
    +kind(native_image, //src/kt/...)"

# Dir used to stage artifacts for CI
export STAGING_DIR="artifacts"

PLATFORM="macos"
if [[ "$(uname -s)" = "Linux" ]]; then
    PLATFORM="linux"
fi
export PLATFORM
