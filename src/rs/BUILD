load("@crates//:defs.bzl", "all_crate_deps")
load("@rules_rust//rust:defs.bzl", "rust_binary")

rust_binary(
    name = "uptime",
    srcs = ["uptime.rs"],
    deps = all_crate_deps(normal = True),
)

# cloudflare/workerd repo is a good example of a Rust Bazel project:
# https://github.com/cloudflare/workerd/blob/a2a20a691dc71af56e9111d1d777e6cf3a2ca9e3/rust-deps/BUILD.bazel#L51
