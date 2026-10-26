load("@rules_android//android:rules.bzl", "android_binary")
load("@rules_kotlin//kotlin:android.bzl", "kt_android_library")

# A minimal Android app that displays uptime. Build the APK with:
#   bazel build //src/android:app
#
# Building needs an Android SDK, found through ANDROID_HOME. To set it for this
# repo only, add this to user.bazelrc:
#   common --repo_env=ANDROID_HOME=/path/to/android/sdk
# Without an SDK, rules_android creates an empty SDK repository, so these
# targets are marked incompatible and builds of //... skip them rather than
# failing.
REQUIRES_ANDROID_SDK = select({
    "@androidsdk//:has_androidsdk": [],
    "//conditions:default": ["@platforms//:incompatible"],
})

kt_android_library(
    name = "app_lib",
    srcs = ["UptimeActivity.kt"],
    custom_package = "ca.macops.uptime",
    manifest = "AndroidManifest.xml",
    target_compatible_with = REQUIRES_ANDROID_SDK,
)

android_binary(
    name = "app",
    manifest = "AndroidManifest.xml",
    target_compatible_with = REQUIRES_ANDROID_SDK,
    deps = [":app_lib"],
)
