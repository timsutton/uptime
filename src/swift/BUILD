load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

# Bazel Platforms Cookbook: https://docs.google.com/document/d/1UZaVcL08wePB41ATZHcxQV4Pu1YfA1RvvWm8FbZHuW8/edit
config_setting(
    name = "platform_macos_apple_silicon",
    constraint_values = [
        "@platforms//cpu:arm64",
        "@platforms//os:macos",
    ],
)

config_setting(
    name = "platform_macos_intel",
    constraint_values = [
        "@platforms//cpu:x86_64",
        "@platforms//os:macos",
    ],
)

config_setting(
    name = "platform_linux",
    constraint_values = ["@platforms//os:linux"],
)

# We can look more towards building a full CLI application to get things like
# deployment targets, etc. But also that'd (probably?) mean defining bundle ID and all that.
swift_binary(
    name = "uptime",
    # There's also an `uptime_processinfo.swift` with a simpler implementation,
    # although it can be inaccurate on macOS 14.4.x on Apple Silicon because Apple broke
    # clock_gettime in this release.
    srcs = ["uptime_c.swift"],
    copts = select({
        ":platform_macos_apple_silicon": ["--target=arm64-apple-macosx13"],
        ":platform_macos_intel": ["--target=x86_64-apple-macosx13"],
        "//conditions:default": [],
    }),
)

# TODO: for linux we need to provide different flags to ensure the included runtime
#       libs are statically-linked:
#       https://stackoverflow.com/a/78075257
