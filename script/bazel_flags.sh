#!/bin/bash

# Enable only when debugging Bazel build failures in CI. This was useful for the
# macOS 14 portable Ruby native extension failure, but is too noisy by default.
ENABLE_VERBOSE_BAZEL_BUILD_LOGS="${ENABLE_VERBOSE_BAZEL_BUILD_LOGS:-0}"

# Detect the highest available Xcode version on macOS
XCODE_VERSION_FLAG=""
if [[ "${PLATFORM}" == "macos" ]]; then
	highest_version=""
	while IFS= read -r xcode_path; do
		plist_path="${xcode_path}/Contents/Info.plist"
		version=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${plist_path}" 2>/dev/null || true)
		if [[ -z "${highest_version}" ]] || [[ "$(printf '%s\n%s' "${version}" "${highest_version}" | sort -V | tail -n1)" == "${version}" ]]; then
			highest_version="${version}"
		fi
	done < <(mdfind "kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'" 2>/dev/null)

	XCODE_VERSION_FLAG="--xcode_version=${highest_version}"
	echo "Detected Xcode version: ${highest_version}"
fi

BAZEL_BUILD_FLAGS=(--config="${PLATFORM}" ${XCODE_VERSION_FLAG:+"${XCODE_VERSION_FLAG}"})
if [[ "${ENABLE_VERBOSE_BAZEL_BUILD_LOGS}" == "1" ]]; then
	BAZEL_BUILD_FLAGS+=(--sandbox_debug --verbose_failures)
fi
