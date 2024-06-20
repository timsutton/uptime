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

# TODO: deps.sh is down here because it needs curl. We could move the curl installation out of install_apt_packages
#       and rename it to be just the stuff we need for build-essentials, etc.
# shellcheck source=deps.sh
source ./script/deps.sh

bazel info
bazel build //...

# At this point these are only lint-type checks
bazel test --test_output=errors //...

for tgt in $(bazel query "${BINARIES_QUERY}"); do
    bazel run --config=quiet "${tgt}"
done
