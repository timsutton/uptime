#!/bin/bash

set -euo pipefail

# shellcheck source=deps.sh
source ./script/deps.sh

if [[ "${platform}" == "linux" ]]; then
    bazel run --config=quiet //src/c:uptime
    bazel run --config=quiet //src/go:uptime
    bazel run --config=quiet //src/py:uptime
    bazel run --config=quiet //src/rs:uptime

    bazel build --config=quiet --compilation_mode=opt //src/c:uptime
    bazel build --config=quiet --compilation_mode=opt //src/go:uptime
    bazel build --config=quiet --compilation_mode=opt //src/py:uptime
    bazel build --config=quiet --compilation_mode=opt //src/rs:uptime
fi

if [[ "${platform}" == "macos" ]]; then
    # TODO: rb isn't ready yet
    for tgt in $(bazel query 'kind(.*_binary, //src/... except //src/rb/...)'); do
        bazel run --config=quiet "${tgt}"
    done

    for tgt in $(bazel query 'kind(.*_binary, //src/... except //src/rb/...)'); do
        bazel build --config=quiet --compilation_mode=opt "${tgt}"
    done
fi
