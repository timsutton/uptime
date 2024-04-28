#!/bin/bash

set -euo pipefail

# shellcheck source=deps.sh
source ./script/deps.sh

query_linux="kind(.*_binary, //src/... except //src/swift/...)"
query_macos="kind(.*_binary, //src/...)"

if [[ "${platform}" == "linux" ]]; then
    # Note, on Linux we may need to set a couple extra things here to support ruby-build:
    export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
    # export LANG="en_US.UTF-8"
    query="${query_linux}"
fi

if [[ "${platform}" == "macos" ]]; then
    query="${query_macos}"
fi

for tgt in $(bazel query "${query}"); do
    bazel build --compilation_mode=opt "${tgt}"
done

for tgt in $(bazel query "${query}"); do
    bazel run --config=quiet "${tgt}"
done
