load("@rules_zig//zig:defs.bzl", "zig_binary")

config_setting(
    name = "linux",
    constraint_values = [
        "@platforms//os:linux",
    ],
)

config_setting(
    name = "macos",
    constraint_values = [
        "@platforms//os:macos",
    ],
)

zig_binary(
    name = "uptime",
    cdeps = ["@rules_zig//zig/lib:libc"],
    main = select({
        ":macos": "uptime_darwin.zig",
        ":linux": "uptime_linux.zig",
    }),
)
