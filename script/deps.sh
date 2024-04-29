#!/bin/bash

function install_swift_for_linux() {
  set -x
  swift_version="5.10"
  ubuntu_version=$(awk -F= '/DISTRIB_RELEASE/ {print $2}' /etc/lsb-release)
  # Because Swift Linux releases put a 'aarch64' in the URL for Arm releases, and nothing at all for x86_64
  arch="$(uname -m)"
  if [[ "${arch}" = "arm64" ]] || [[ "${arch}" = "aarch64" ]]; then
    arch_url_fragment="-aarch64"
  fi

  if [[ "${arch}" = "x86_64" ]]; then
    arch_url_fragment=""
  fi

  install_dir=$(mktemp -d)
  pushd "${install_dir}" || exit
  url="https://download.swift.org/swift-${swift_version}-release/ubuntu$(echo "$ubuntu_version" | sed 's/\.//g')${arch_url_fragment}/swift-${swift_version}-RELEASE/swift-${swift_version}-RELEASE-ubuntu${ubuntu_version}${arch_url_fragment}.tar.gz"
  curl -sfL "${url}" | tar -xz -f -
  popd || exit
  # shellcheck disable=SC2155
  export PATH="${install_dir}/swift-${swift_version}-RELEASE-ubuntu22.04-$(arch)/usr/bin:${PATH}"

  echo "Listing the dir contents we've just added to PATH:"
  ls -la "${install_dir}/swift-${swift_version}-RELEASE-ubuntu22.04-$(arch)/usr/bin"
  set +x
}

export platform="macos"
if [[ "$(uname -s)" == "Linux" ]]; then
  if [[ "$(awk -F= '/DISTRIB_ID/ {print $2}' /etc/lsb-release)" != "Ubuntu" ]]; then
    echo "On Linux, only Ubuntu platform is supported for building (for now)" >&2
    exit 1
  fi
  export platform="linux"
  install_swift_for_linux

  # GHA's Ubuntu runner already had Swift installed, but in a way that is problematic.
  # (maybe we can fix this with them in the future):
  # https://github.com/actions/runner-images/blob/a76eae469e4c8c16b0f91c38e17f9e1ffb5c633d/images/ubuntu/scripts/build/install-swift.sh#L50-L56
  if [ -n "${GITHUB_ACTION}" ]; then
    sudo rm -f /usr/local/bin/swift*
    unset SWIFT_PATH
  fi
fi

if [[ "${platform}" == "macos" ]]; then
  command -v bazelisk >/dev/null || brew install bazelisk
fi
