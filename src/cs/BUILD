load(":defs.bzl", "dotnet_singlefile_binary")

config_setting(
    name = "macos_arm64",
    constraint_values = [
        "@platforms//os:macos",
        "@platforms//cpu:aarch64",
    ],
)

config_setting(
    name = "linux_arm64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:arm64",
    ],
)

config_setting(
    name = "linux_x86_64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)

dotnet_singlefile_binary(
    name = "uptime",
    project = "uptime.csproj",
    srcs = ["Program.cs"],
    runtime_identifier = select({
        ":macos_arm64": "osx-arm64",
        ":linux_arm64": "linux-arm64",
        ":linux_x86_64": "linux-x64",
        "//conditions:default": "unsupported",
    }),
    target_compatible_with = select({
        ":macos_arm64": [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ],
        ":linux_arm64": [
            "@platforms//os:linux",
            "@platforms//cpu:arm64",
        ],
        ":linux_x86_64": [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        "//conditions:default": ["@platforms//:incompatible"],
    }),
)
