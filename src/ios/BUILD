load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")
load("@platforms//host:constraints.bzl", "HOST_CONSTRAINTS")

# A minimal iOS app that displays uptime. Run it in the simulator with:
#   bazel run //src/ios:app
#
# Only for local simulator builds for now: there is no provisioning profile, so
# it can't be installed on a device.

# Building for iOS needs Xcode, so skip these targets in builds of //... on other
# hosts. This checks the host rather than the target platform, because
# ios_application always builds for an iOS platform.
MACOS_HOST_ONLY = [] if "@platforms//os:osx" in HOST_CONSTRAINTS else ["@platforms//:incompatible"]

swift_library(
    name = "app_lib",
    srcs = ["UptimeApp.swift"],
    target_compatible_with = MACOS_HOST_ONLY,
)

ios_application(
    name = "app",
    bundle_id = "ca.macops.uptime",
    families = ["iphone"],
    infoplists = ["Info.plist"],
    minimum_os_version = "18.0",
    target_compatible_with = MACOS_HOST_ONLY,
    deps = [":app_lib"],
)
