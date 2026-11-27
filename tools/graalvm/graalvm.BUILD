load("@rules_graalvm//internal:toolchain.bzl", "graalvm_sdk")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "files",
    srcs = glob(["**/*"]),
)

graalvm_sdk(
    name = "gvm",
    gvm_files = ":files",
    native_image_bin = "bin/native-image",
)
