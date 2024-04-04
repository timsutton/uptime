load("@bazel_skylib//lib:selects.bzl", "selects")
load("@rules_rust//crate_universe:defs.bzl", "crate", "crates_vendor")
load("@rules_rust//rust:defs.bzl", "rust_binary")

rust_binary(
    name = "uptime",
    srcs = ["uptime.rs"],
    edition = "2021",
    deps = [
        "@crates//:libc",
    ],
)
# # Borrowed from cloudflare/workerd:
# # https://github.com/ObsidianMinor/workerd/blob/cb61734c3fa6e3e29971bf7805fed3f555825465/rust-deps/BUILD.bazel
# selects.config_setting_group(
#     name = "linux_x64",
#     match_all = [
#         "@platforms//os:linux",
#         "@platforms//cpu:x86_64",
#     ],
# )
# selects.config_setting_group(
#     name = "linux_arm64",
#     match_all = [
#         "@platforms//os:linux",
#         "@platforms//cpu:aarch64",
#     ],
# )
# selects.config_setting_group(
#     name = "macos_x64",
#     match_all = [
#         "@platforms//os:macos",
#         "@platforms//cpu:x86_64",
#     ],
# )
# selects.config_setting_group(
#     name = "macos_arm64",
#     match_all = [
#         "@platforms//os:macos",
#         "@platforms//cpu:aarch64",
#     ],
# )
# selects.config_setting_group(
#     name = "win_x64",
#     match_all = [
#         "@platforms//os:windows",
#         "@platforms//cpu:x86_64",
#     ],
# )
# CARGO_BAZEL = select({
#     ":linux_x64": "@cargo_bazel_linux_x64//file:downloaded",
#     ":linux_arm64": "@cargo_bazel_linux_arm64//file:downloaded",
#     ":macos_x64": "@cargo_bazel_macos_x64//file:downloaded",
#     ":macos_arm64": "@cargo_bazel_macos_arm64//file:downloaded",
#     ":win_x64": "@cargo_bazel_win_x64//file:downloaded.exe",
# })

# # Generates a repository containing all the crates we reference from our
# # rust workspace
# # To repin crates: bazel run //rust-deps:crates_vendor -- --repin
# crates_vendor(
#     name = "crates_vendor",
#     annotations = {
#         "lolhtml": [crate.annotation(
#             shallow_since = "1686149015 +0100",
#         )],
#         "lol_html": [crate.annotation(
#             shallow_since = "1686149015 +0100",
#         )],
#     },
#     cargo_bazel = CARGO_BAZEL,
#     mode = "remote",
#     packages = {
#         "libc": crate.spec(
#             version = "0.2",
#         ),
#     },
#     supported_platform_triples = [
#         "aarch64-apple-darwin",
#         "x86_64-apple-darwin",
#         "aarch64-unknown-linux-gnu",
#         "x86_64-unknown-linux-gnu",
#         "x86_64-pc-windows-msvc",
#     ],
#     # Not needed, we have a well-defined set of supported platforms
#     generate_target_compatible_with = False,
# )
