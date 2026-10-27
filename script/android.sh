#!/bin/bash
#
# Sets up an Android SDK and emulator on macOS, then builds //src/android:app and
# launches it. Safe to re-run: each step is skipped if it's already done.
#
# Usage: ./script/android.sh

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "This script only supports macOS" >&2
	exit 1
fi

cd "$(git rev-parse --show-toplevel)"

API_LEVEL=36
BUILD_TOOLS_VERSION=36.1.0
AVD_NAME=uptime

ABI=arm64-v8a
if [[ "$(uname -m)" == "x86_64" ]]; then
	ABI=x86_64
fi
SYSTEM_IMAGE="system-images;android-${API_LEVEL};google_apis;${ABI}"

BREW_PREFIX="$(brew --prefix)"

# The SDK command-line tools need Java 17 or later.
MIN_JAVA_VERSION=17

function java_major_version() {
	"$1/bin/java" -XshowSettings:properties -version 2>&1 |
		awk -F' = ' '/java.specification.version/ { split($2, v, "."); print v[1] }'
}

# Prints the first Java home that is new enough, checking JAVA_HOME, the JDKs
# macOS knows about, and Homebrew's openjdk formulae, which are keg-only and so
# invisible to java_home.
function find_java_home() {
	local candidates=()
	if [[ -n "${JAVA_HOME:-}" ]]; then
		candidates+=("${JAVA_HOME}")
	fi
	if java_home="$(/usr/libexec/java_home -v "${MIN_JAVA_VERSION}+" 2>/dev/null)"; then
		candidates+=("${java_home}")
	fi
	for keg in "${BREW_PREFIX}"/opt/openjdk "${BREW_PREFIX}"/opt/openjdk@*; do
		candidates+=("${keg}")
	done

	local version
	for candidate in "${candidates[@]}"; do
		[[ -x "${candidate}/bin/java" ]] || continue
		version="$(java_major_version "${candidate}")"
		if [[ "${version}" =~ ^[0-9]+$ ]] && ((version >= MIN_JAVA_VERSION)); then
			echo "${candidate}"
			return
		fi
	done
	return 1
}

if ! JAVA_HOME="$(find_java_home)"; then
	brew install openjdk
	JAVA_HOME="$(find_java_home)"
fi
export JAVA_HOME
echo "Using Java from ${JAVA_HOME}"

if [[ ! -d "${BREW_PREFIX}/share/android-commandlinetools" ]]; then
	brew install --cask android-commandlinetools
fi
export ANDROID_HOME="${BREW_PREFIX}/share/android-commandlinetools"

android="${ANDROID_HOME}/cmdline-tools/latest/bin/android"
avdmanager="${ANDROID_HOME}/cmdline-tools/latest/bin/avdmanager"
adb="${ANDROID_HOME}/platform-tools/adb"

# Unlike sdkmanager, `android sdk install` accepts the SDK licenses itself.
"${android}" --sdk="${ANDROID_HOME}" sdk install \
	"platform-tools" \
	"platforms;android-${API_LEVEL}" \
	"build-tools;${BUILD_TOOLS_VERSION}" \
	"emulator" \
	"${SYSTEM_IMAGE}"

# `android emulator create` can't choose the AVD's name or system image (it
# picks a Play Store image for a device profile), so avdmanager, which isn't
# deprecated, still creates the AVD.
if ! "${android}" --sdk="${ANDROID_HOME}" emulator list | grep -qx "${AVD_NAME}"; then
	echo no | "${avdmanager}" create avd --name "${AVD_NAME}" --package "${SYSTEM_IMAGE}"
fi

# `android emulator start` returns once Android has finished booting.
if ! "${adb}" devices | grep -q "device$"; then
	"${android}" --sdk="${ANDROID_HOME}" emulator start "${AVD_NAME}"
fi

bazel build --repo_env=ANDROID_HOME="${ANDROID_HOME}" //src/android:app
"${adb}" install -r bazel-bin/src/android/app.apk
"${adb}" shell am start -n ca.macops.uptime/.UptimeActivity
