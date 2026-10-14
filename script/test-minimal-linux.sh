#!/bin/bash

set -euo pipefail

workspace="$(pwd)"
swift_output="$(mktemp -d)"
trap 'rm -rf "$swift_output"' EXIT

find artifacts -type f -path '*/src/swift/uptime' -print -quit | grep -q .

docker run --rm \
	--volume "${workspace}:/workspace:ro" \
	--workdir /tmp/uptime \
	ubuntu:24.04 bash -euo pipefail -c '
		apt-get update
		apt-get install -y --no-install-recommends libicu74
		cp -a /workspace/script .
		cp -a /workspace/artifacts .
		./script/test.sh
	'

docker run --rm \
	--volume "${workspace}:/workspace:ro" \
	--volume "${swift_output}:/output" \
	--workdir /tmp/uptime \
	ubuntu:24.04 bash -euo pipefail -c '
		tar -C /workspace --exclude=./.git --exclude=./.context \
			--exclude=./artifacts --exclude="./bazel-*" -cf - . | tar -xf -
		apt-get update
		apt-get install -y --no-install-recommends sudo
		source ./script/common.sh
		install_apt_packages
		source ./script/deps.sh
		bazel --output_user_root="$(mktemp -d)" run \
			--config=linux --disk_cache= --remote_cache= --noremote_accept_cached \
			//src/swift:uptime
		cp -L bazel-bin/src/swift/uptime /output/uptime
	'

docker run --rm \
	--volume "${swift_output}:/output:ro" \
	ubuntu:24.04 /output/uptime
