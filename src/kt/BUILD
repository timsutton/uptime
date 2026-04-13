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
    deps = [
        "@maven//:com_github_oshi_oshi_core",
    ],
)

native_image(
    name = "uptime",
    executable_name = "%target%",
    extra_args = ["-H:+AddAllCharsets"],
    include_resources = "com/sun/jna/.*",
    jni_configuration = "jna-jni-config.json",
    main_class = select({
        ":linux": "MainLinuxKt",
        ":macos": "MainDarwinKt",
    }),
    native_image_tool = "@graalvm//:native-image",
    proxy_configuration = "jna-proxy-config.json",
    reflection_configuration = "jna-reflection-config.json",
    deps = [":uptime_jar"],
)
