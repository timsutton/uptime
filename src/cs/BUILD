load(":defs.bzl", "dotnet_nativeaot_binary", "dotnet_singlefile_binary")

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

# Remote workers can't reach nuget.org, so on Linux x86_64 the packages are
# Bazel inputs. Other platforms download them while publishing.
RUNTIME_PACKAGES = [
    "@nupkg_microsoft.aspnetcore.app.runtime.linux-x64//file",
    "@nupkg_microsoft.net.illink.tasks//file",
    "@nupkg_microsoft.netcore.app.runtime.linux-x64//file",
]

NATIVEAOT_PACKAGES = RUNTIME_PACKAGES + [
    "@nupkg_microsoft.dotnet.ilcompiler//file",
    "@nupkg_microsoft.netcore.app.runtime.nativeaot.linux-x64//file",
    "@nupkg_runtime.linux-x64.microsoft.dotnet.ilcompiler//file",
]

dotnet_singlefile_binary(
    name = "uptime",
    srcs = ["Program.cs"],
    nuget_packages = select({
        ":linux_x86_64": RUNTIME_PACKAGES,
        "//conditions:default": [],
    }),
    project = "uptime.csproj",
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

dotnet_nativeaot_binary(
    name = "uptime_aot",
    srcs = ["Program.cs"],
    nuget_packages = select({
        ":linux_x86_64": NATIVEAOT_PACKAGES,
        "//conditions:default": [],
    }),
    project = "uptime.csproj",
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
