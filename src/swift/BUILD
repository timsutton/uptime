load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

# Bazel Platforms Cookbook: https://docs.google.com/document/d/1UZaVcL08wePB41ATZHcxQV4Pu1YfA1RvvWm8FbZHuW8/edit
config_setting(
    name = "macos_apple_silicon",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:macos",
    ],
)

config_setting(
    name = "macos_intel",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:macos",
    ],
)

# We can look more towards building a full CLI application to get things like
# deployment targets, etc. But also that'd (probably?) mean defining bundle ID and all that.
swift_binary(
    name = "uptime",
    # There's also an `uptime_c.swift` with an alternate implementation
    srcs = ["uptime_processinfo.swift"],
    copts = select({
        ":macos_apple_silicon": ["--target=arm64-apple-macosx13"],
        ":macos_intel": ["--target=x86_64-apple-macosx13"],
        "//conditions:default": [],
    }),
)
