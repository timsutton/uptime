load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

swift_binary(
    name = "uptime",
    srcs = ["uptime.swift"],
    # can we set the arch dynamically, and is this even the best place for this config
    copts = ["--target=arm64-apple-macosx13"],
)
