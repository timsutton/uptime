load("@rules_ruby//ruby:defs.bzl", "rb_binary", "rb_library")

# there's not really any 'lib', just pretending like we have one
rb_library(
    name = "lib_uptime",
    srcs = ["uptime.rb"],
)

rb_binary(
    name = "uptime",
    main = "uptime.rb",
    deps = [":lib_uptime"],
)
