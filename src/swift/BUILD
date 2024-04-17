load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

# We can look more towards building a full CLI application to get things like
# deployment targets, etc. But also that'd (probably?) mean defining bundle ID and all that.
swift_binary(
    name = "uptime",
    srcs = ["uptime.swift"],
    # can we set the arch dynamically, and is this even the best place for this config
    copts = ["--target=arm64-apple-macosx13"],
)
