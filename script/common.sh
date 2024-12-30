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

# TODO: comment for why this is needed
export LANG="en_US.UTF-8"

function install_apt_packages() {
    apt-get update
    if ! command -v curl >/dev/null; then
        apt-get install -y curl
    fi

    if ! command -v javac >/dev/null; then
        apt-get install -y openjdk-17-jdk-headless
    fi

    # Note, on Linux we may need to set a couple extra things here to support ruby-build
    if [ -z "${JAVA_HOME:-}" ]; then
        # shellcheck disable=SC2155
        export JAVA_HOME="$(dirname "$(dirname "$(realpath "$(which javac)")")")"
    fi

    # what's a good way to detect if we need basic things like libc6-dev?
    # ..and could we get away with installing a lot fewer packages than all of build-essential?
    # ..zlib1g-dev is needed for GraalVM native-image
    # ..libffi/libyaml is needed for Ruby build
    apt-get install -y \
        build-essential \
        libffi-dev \
        libncurses6 \
        libyaml-dev \
        zlib1g-dev
}
export -f install_apt_packages
