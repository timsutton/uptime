load("@build_bazel_rules_swift//swift:swift.bzl", "swift_binary")

# We can look more towards building a full CLI application to get things like
# deployment targets, etc. But also that'd (probably?) mean defining bundle ID and all that.
swift_binary(
    name = "uptime",
    srcs = ["uptime.swift"],
    # TODO: set the arch dynamically using platforms, and is this even the best place for this config
    # see Bazel Platforms Cookbook: https://docs.google.com/document/d/1UZaVcL08wePB41ATZHcxQV4Pu1YfA1RvvWm8FbZHuW8/edit
    copts = select({
        "@platforms//os:osx": ["--target=arm64-apple-macosx13"],
        "//conditions:default": [],
    }),
)
