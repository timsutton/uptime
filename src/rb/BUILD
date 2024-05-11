load("@rules_ruby//ruby:defs.bzl", "rb_binary", "rb_library", "rb_test")

package(default_visibility = ["//:__subpackages__"])

# there's not really any 'lib', just pretending like we have one,
# I wasn't able to avoid it when wanting to have a 'bazel run'-able target
rb_library(
    name = "lib_uptime",
    srcs = ["uptime.rb"],
)

rb_binary(
    name = "uptime",
    main = "uptime.rb",
    deps = [
        ":lib_uptime",
        "@bundle",
    ],
)

# inspired from https://github.com/SeleniumHQ/selenium/blob/67ba0054e34cff220e68b457e88a0859114ff250/rb/BUILD.bazel#L179
rb_test(
    name = "lint",
    srcs = glob([
        "**/*.rb",
    ] + ["Gemfile"]),
    args = [
        "--config=src/rb/.rubocop.yml",
        "src/rb/*.rb",
        "src/rb/Gemfile",
    ],
    data = [".rubocop.yml"],
    main = "@bundle//bin:rubocop",
    tags = ["no-sandbox"],
    deps = ["@bundle"],
)
