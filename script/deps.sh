#!/bin/bash

# shellcheck source=common.sh
source ./script/common.sh

BAZELISK_VERSION=1.25.0
SWIFT_VERSION=6.1

function install_bazelisk() {
	if command -v bazelisk >/dev/null; then
		return
	fi

	bazelisk_version="${BAZELISK_VERSION}"
	arch=amd64
	if [[ "$(uname -m)" == "aarch64" ]]; then
		arch=arm64
	fi
	bazelisk_path="$(mktemp -d)"
	curl -sfL -o "${bazelisk_path}/bazelisk" \
		"https://github.com/bazelbuild/bazelisk/releases/download/v${bazelisk_version}/bazelisk-linux-${arch}"
	cp "${bazelisk_path}/bazelisk" "${bazelisk_path}/bazel"
	chmod +x "${bazelisk_path}"/*
	export PATH="${bazelisk_path}:${PATH}"
	echo "Installed Bazelisk to ${bazelisk_path} and added to PATH"
}

# Can potentially optimize this based on what rules_swift's CI does for Linux:
# https://github.com/bazelbuild/rules_swift/blob/master/.bazelci/presubmit.yml#L13-L19
function install_swift_for_linux() {
	swift_version="${SWIFT_VERSION}"
	ubuntu_version=$(awk -F= '/DISTRIB_RELEASE/ {print $2}' /etc/lsb-release)

	# Because Swift Linux releases put a 'aarch64' in the URL for Arm releases, and nothing at all for x86_64
	arch="$(uname -m)"
	if [[ "${arch}" = "arm64" ]] || [[ "${arch}" = "aarch64" ]]; then
		arch_url_fragment="-aarch64"
	fi

	if [[ "${arch}" = "x86_64" ]]; then
		arch_url_fragment=""
	fi

	install_dir="${HOME}/.cache/swift-${swift_version}-${arch}"
	if [[ -d "${install_dir}" ]] && [[ -x "${install_dir}/usr/bin/swiftc" ]]; then
		export PATH="${install_dir}/usr/bin:${PATH}"
		return
	fi

	mkdir -p "${install_dir}"

	pushd "${install_dir}" || exit
	# shellcheck disable=SC2001
	url="https://download.swift.org/swift-${swift_version}-release/ubuntu$(echo "$ubuntu_version" | sed 's/\.//g')${arch_url_fragment}/swift-${swift_version}-RELEASE/swift-${swift_version}-RELEASE-ubuntu${ubuntu_version}${arch_url_fragment}.tar.gz"
	curl -sfL "${url}" | tar -xz --strip-components 1 -f -
	popd || exit
	# shellcheck disable=SC2155
	export PATH="${install_dir}/usr/bin:${PATH}"
}

if [[ "${PLATFORM}" = "linux" ]]; then
	if [[ "$(awk -F= '/DISTRIB_ID/ {print $2}' /etc/lsb-release)" != "Ubuntu" ]]; then
		echo "On Linux, only Ubuntu platform is supported for building (for now)" >&2
		exit 1
	fi

	install_bazelisk
	install_swift_for_linux
fi

if [[ "${PLATFORM}" == "macos" ]]; then
	command -v bazelisk >/dev/null || brew install bazelisk
fi
