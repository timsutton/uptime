load("@build_bazel_rules_apple//apple:ios.bzl", "ios_application")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

# A minimal iOS app that displays uptime. Run it in the simulator with:
#   bazel run //src/ios:app
#
# Only for local simulator builds for now: there is no provisioning profile, so
# it can't be installed on a device.

# Skip these targets in Linux builds of //..., which lack the Apple SDKs.
NOT_LINUX = select({
    "@platforms//os:linux": ["@platforms//:incompatible"],
    "//conditions:default": [],
})

swift_library(
    name = "app_lib",
    srcs = ["UptimeApp.swift"],
    target_compatible_with = NOT_LINUX,
)

ios_application(
    name = "app",
    bundle_id = "ca.macops.uptime",
    families = ["iphone"],
    infoplists = ["Info.plist"],
    minimum_os_version = "18.0",
    target_compatible_with = NOT_LINUX,
    deps = [":app_lib"],
)
