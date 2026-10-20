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
	sudo apt-get update
	sudo apt-get install -y --no-install-recommends libcurl4-openssl-dev
	if ! command -v curl >/dev/null; then
		sudo apt-get install -y curl
	fi

	if ! command -v javac >/dev/null; then
		sudo apt-get install -y openjdk-17-jdk-headless
	fi

	# Needed for building on a bare Ubuntu image; GitHub-hosted runners already have these.
	# - clang: the cc toolchain, as .bazelrc sets CC=clang on Linux
	# - git: required by cgrindel_bazel_starlib's git toolchain (pulled in via Swift deps)
	# - libncurses6: runtime dependency of the downloaded swiftc
	# - libxml2-dev: -lxml2 when statically linking Foundation
	# - lld: rules_swift passes `-z nostart-stop-gc`, which ld.gold rejects
	sudo apt-get install -y --no-install-recommends clang git libncurses6 libxml2-dev lld

	if [ -z "${JAVA_HOME:-}" ]; then
		# shellcheck disable=SC2155
		export JAVA_HOME="$(dirname "$(dirname "$(realpath "$(which javac)")")")"
	fi
}
export -f install_apt_packages
