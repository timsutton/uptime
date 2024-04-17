#!/bin/bash

set -euo pipefail

source ./script/deps.sh

if [[ "${platform}" == "linux" ]]; then
    bazel run --config=quiet //src/c:uptime
fi

if [[ "${platform}" == "macos" ]]; then
    # TODO: rb isn't ready yet
    for tgt in $(bazel query 'kind(.*_binary, //src/... except //src/rb/...)'); do
        bazel run --config=quiet "${tgt}"
    done
fi
