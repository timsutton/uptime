load("@rules_d//d:defs.bzl", "d_binary")

config_setting(
    name = "macos_arm64",
    constraint_values = [
        "@platforms//os:macos",
        "@platforms//cpu:arm64",
    ],
)

config_setting(
    name = "macos_x86_64",
    constraint_values = [
        "@platforms//os:macos",
        "@platforms//cpu:x86_64",
    ],
)

# LDC targets the host macOS version by default, which makes ld warn that the
# object was built for a newer macOS than the one being linked for. Match the
# --macos_minimum_os=11.0 pinned in .bazelrc.
MACOS_MINIMUM_OS = "11.0"

d_binary(
    name = "uptime",
    srcs = ["uptime.d"],
    dopts = select({
        ":macos_arm64": ["-mtriple=arm64-apple-macos" + MACOS_MINIMUM_OS],
        ":macos_x86_64": ["-mtriple=x86_64-apple-macos" + MACOS_MINIMUM_OS],
        "//conditions:default": [],
    }),
)
