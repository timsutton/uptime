load("@rules_graalvm//graalvm:defs.bzl", "native_image")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_binary")

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

kt_jvm_binary(
    name = "uptime_jar",
    srcs = select({
        ":linux": ["MainLinux.kt"],
        ":macos": ["MainDarwin.kt"],
    }),
    main_class = select({
        ":linux": "MainLinuxKt",
        ":macos": "MainDarwinKt",
    }),
    visibility = ["//visibility:private"],
    # deps = [
    #     "@maven_jvm_external//:com_github_oshi",
    # ],
)

# java_library(
#     name = "my_lib",
#     exports = [
#         "@maven_jvm_external//:com_github_oshi",
#     ],
# )

native_image(
    name = "uptime",
    executable_name = "%target%",
    main_class = select({
        ":linux": "MainLinuxKt",
        ":macos": "MainDarwinKt",
    }),
    native_image_tool = "@graalvm//:native-image",
    deps = [":uptime_jar"],
)
