#!/bin/bash

set -euo pipefail

set -x
env | sort

# shellcheck source=deps.sh
source ./script/deps.sh

# focused to only testing Swift for now on Linux
query_linux="kind(.*_binary, //src/swift/...)"
query_macos="kind(.*_binary, //src/...)"

if [[ "${platform}" == "linux" ]]; then
    # Note, on Linux we may need to set a couple extra things here to support ruby-build:
    export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
    # export LANG="en_US.UTF-8"
    query="${query_linux}"
fi

bazel query "${query}" | xargs bazel build --compilation_mode=opt

for tgt in $(bazel query "${query}"); do
    bazel run --config=quiet "${tgt}"
done
