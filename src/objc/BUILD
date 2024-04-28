load("@build_bazel_apple_support//lib:repositories.bzl", "apple_support_dependencies")

# load("@rules_cc//cc:defs.bzl", "cc_binary")
load("@build_bazel_rules_apple//apple:apple_binary.bzl", "apple_binary")

# package(default_visibility = ["//visibility:public"])

apple_binary(
    name = "uptime",
    srcs = ["uptime.m"],
    minimum_os_version = "10.11",
    platform_type = "macos",
)
