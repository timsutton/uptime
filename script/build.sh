#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

# shellcheck source=deps.sh
source ./script/deps.sh

if [[ "${PLATFORM}" == "linux" ]]; then
    # Note, on Linux we may need to set a couple extra things here to support ruby-build
    if [ -z "${JAVA_HOME:-}" ]; then
        # shellcheck disable=SC2155
        export JAVA_HOME="$(dirname "$(dirname "$(realpath "$(which javac)")")")"
    fi
    export LANG="en_US.UTF-8"
fi

bazel info

bazel build //...

for tgt in $(bazel query "${BINARIES_QUERY}"); do
    bazel run --config=quiet "${tgt}"
done
