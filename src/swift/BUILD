load("@bazel_skylib//rules:common_settings.bzl", "string_flag")
load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")
# load("//testapp:defs.bzl", "var_providing_rule")

string_flag(
    name = "swift_distribution_dir",
    build_setting_default = "",
    make_variable = "SWIFT_DISTRIBUTION_DIR",
)

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

# linux_static_link_libs_dir = "$(SWIFT_DISTRIBUTION_DIR)/usr/lib/swift_static/linux"

# We can look more towards building a full CLI application to get things like
# deployment targets, etc. But also that'd (probably?) mean defining bundle ID and all that.
swift_binary(
    name = "uptime",
    # There's also an `uptime_processinfo.swift` with a simpler implementation,
    # although it can be inaccurate on macOS 14.4.x on Apple Silicon because Apple broke
    # clock_gettime in this release.
    srcs = ["uptime_c.swift"],
    copts = select(
        {
            ":platform_macos_apple_silicon": ["--target=arm64-apple-macosx13"],
            ":platform_macos_intel": ["--target=x86_64-apple-macosx13"],

            # On Linux, since the Swift stdlib is not shipped by default on the OS, we instruct
            # swiftc to statically link the stdlib. See this SE proposal for more details:
            # https://github.com/swiftlang/swift-evolution/blob/main/proposals/0342-static-link-runtime-libraries-by-default-on-supported-platforms.md
            ":platform_linux": ["-static-stdlib"],
            "//conditions:default": [],
        },
    ),
    # static linking on Linux needs at least these lib inclusions:
    # -lDispatchStubs
    # -lCoreFoundation
    # -luuid
    linkopts = select(
        {
            # HACK: hardcoding the path to swift runtime libs including the user path
            # ":platform_linux": ["-L{}/usr/lib/swift_static/linux".format("/root/.cache/swift-5.10.1-aarch64")],
            ":platform_linux": ["-L$(SWIFT_DISTRIBUTION_DIR)/usr/lib/swift_static/linux"],
            "//conditions:default": [],
        },
    ),
)

# TODO: for linux we need to provide different flags to ensure the included runtime
#       libs are statically-linked:
#       https://stackoverflow.com/a/78075257
