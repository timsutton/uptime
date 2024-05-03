#!/bin/bash

set -euo pipefail

# shellcheck source=deps.sh
source ./script/deps.sh

query="kind(.*_binary, //src/...)"

if [[ "${platform}" == "linux" ]]; then
    # Note, on Linux we may need to set a couple extra things here to support ruby-build
    if [ -z "${JAVA_HOME:-}" ]; then
        # shellcheck disable=SC2155
        export JAVA_HOME="$(dirname "$(dirname "$(realpath "$(which javac)")")")"
    fi
    export LANG="en_US.UTF-8"
fi

bazel info

# TODO: kt example seems like it doesn't stage due to the order in which we build things?

bazel query "${query}" | xargs bazel build

for tgt in $(bazel query "${query}"); do
    bazel run --config=quiet "${tgt}"
done
