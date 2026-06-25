load("@gazelle//:def.bzl", "gazelle")
load("@rules_kotlin//kotlin:core.bzl", "define_kt_toolchain")

gazelle(name = "gazelle")

define_kt_toolchain(
    name = "kotlin_2_4_toolchain",
    api_version = "2.4",
    language_version = "2.4",
)

alias(
    name = "format",
    actual = "//tools/format",
)
