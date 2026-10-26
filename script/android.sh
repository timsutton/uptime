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

# The SDK command-line tools need Java 17 or later. Homebrew's openjdk@21 is
# keg-only, so point JAVA_HOME at it rather than relying on the java on PATH.
if [[ ! -d "${BREW_PREFIX}/opt/openjdk@21" ]]; then
	brew install openjdk@21
fi
export JAVA_HOME="${BREW_PREFIX}/opt/openjdk@21"

if [[ ! -d "${BREW_PREFIX}/share/android-commandlinetools" ]]; then
	brew install --cask android-commandlinetools
fi
export ANDROID_HOME="${BREW_PREFIX}/share/android-commandlinetools"

sdkmanager="${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager"
avdmanager="${ANDROID_HOME}/cmdline-tools/latest/bin/avdmanager"
adb="${ANDROID_HOME}/platform-tools/adb"
emulator="${ANDROID_HOME}/emulator/emulator"

# `yes` exits with SIGPIPE once sdkmanager stops reading, which pipefail would
# otherwise treat as a failure.
{ yes || true; } | "${sdkmanager}" --licenses >/dev/null
"${sdkmanager}" \
	"platform-tools" \
	"platforms;android-${API_LEVEL}" \
	"build-tools;${BUILD_TOOLS_VERSION}" \
	"emulator" \
	"${SYSTEM_IMAGE}"

if ! "${emulator}" -list-avds | grep -qx "${AVD_NAME}"; then
	echo no | "${avdmanager}" create avd --name "${AVD_NAME}" --package "${SYSTEM_IMAGE}"
fi

if ! "${adb}" devices | grep -q "device$"; then
	echo "Starting the ${AVD_NAME} emulator"
	nohup "${emulator}" -avd "${AVD_NAME}" >/tmp/android-emulator-"${AVD_NAME}".log 2>&1 &
	"${adb}" wait-for-device
fi

echo "Waiting for Android to finish booting"
until [[ "$("${adb}" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; do
	sleep 2
done

bazel build --repo_env=ANDROID_HOME="${ANDROID_HOME}" //src/android:app
"${adb}" install -r bazel-bin/src/android/app.apk
"${adb}" shell am start -n ca.macops.uptime/.UptimeActivity
