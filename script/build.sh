#!/bin/bash

set -euo pipefail

# shellcheck source=common.sh
source ./script/common.sh

if [[ "${PLATFORM}" == "linux" ]]; then
	# A Linux CI runner (e.g. GHA) already has other common dev tools installed, but in
	# case this looks like some other Ubuntu host, then run some additional required apt installs.
	if [ -z "${CI:-}" ]; then
		install_apt_packages
	fi
fi

# TODO: deps.sh is down here because it needs curl. We could move the curl installation out of install_apt_packages
#       and rename it to be just the stuff we need for build-essentials, etc.
# shellcheck source=deps.sh
source ./script/deps.sh

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

bazel info
bazel build --config="${PLATFORM}" ${XCODE_VERSION_FLAG:+"${XCODE_VERSION_FLAG}"} //...

# At this point these are only lint-type checks
bazel test --config="${PLATFORM}" --test_output=errors //...

for tgt in $(bazel query "${BINARIES_QUERY}"); do
	bazel run --config=quiet --config="${PLATFORM}" "${tgt}"
done
