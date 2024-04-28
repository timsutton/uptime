#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh
# shellcheck source=deps.sh
source ./script/deps.sh

target_lang="${1}"
if [[ "${platform}" == "linux" ]]; then
    # Note, on Linux we may need to set a couple extra things here to support ruby-build:
    export JAVA_HOME="$(dirname $(dirname $(realpath $(which javac))))"
    # export LANG="en_US.UTF-8"
fi

bazel build --compilation_mode=opt "//src/${target_lang}:uptime"
bazel run --config=quiet "//src/${target_lang}:uptime"
