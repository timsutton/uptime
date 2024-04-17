#!/bin/bash

export platform="macos"
if [[ "$(uname -s)" == "Linux" ]]; then
  export platform="linux"
fi

if [[ "${platform}" == "macos" ]]; then
  command -v bazelisk >/dev/null || brew install bazelisk
fi
