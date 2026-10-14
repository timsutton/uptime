#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

if [[ "${PLATFORM}" == "linux" ]]; then
	# A Linux CI runner (e.g. GHA) already has other common dev tools installed, but in
	# case this looks like some other Ubuntu host, then run some additional required apt installs.
	if [ -z "${CI:-}" ]; then
		install_apt_packages
	fi
fi

# TODO: deps.sh is down here because Linux Bazelisk installation needs curl. We could move
#       the curl installation out of install_apt_packages.
# shellcheck source=deps.sh
source ./script/deps.sh

source ./script/bazel_flags.sh

bazel info
bazel build "${BAZEL_BUILD_FLAGS[@]}" //...

# At this point these are only lint-type checks
bazel test "${BAZEL_BUILD_FLAGS[@]}" --test_output=errors //...

for tgt in $(bazel query "${BINARIES_QUERY}"); do
	bazel run --config=quiet "${BAZEL_BUILD_FLAGS[@]}" "${tgt}"
done
