#!/bin/bash

# shellcheck source=common.sh
source ./script/common.sh

BAZELISK_VERSION=1.27.0

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

function report_disk_usage() {
	curl -sSfL https://raw.githubusercontent.com/bootandy/dust/refs/heads/master/install.sh | sh
	dust --no-progress /
}

function free_some_disk_space() {
	sudo rm -rf /usr/share/dotnet
	# Other potential candidates could be /usr/local/lib/android/sdk/...
}

if [[ "${PLATFORM}" = "linux" ]]; then
	if [[ "$(awk -F= '/^ID=/ {gsub(/"/, "", $2); print $2}' /etc/os-release)" != "ubuntu" ]]; then
		echo "On Linux, only Ubuntu platform is supported for building (for now)" >&2
		exit 1
	fi

	install_bazelisk
	free_some_disk_space
	# If there's disk space issues, then uncomment report_disk_usage below to see where space is being eaten up
	# report_disk_usage
fi

if [[ "${PLATFORM}" == "macos" ]]; then
	command -v bazelisk >/dev/null || brew install bazelisk
fi
