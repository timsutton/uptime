# uptime

Learning Bazel with a polyglot multi-platform project: a simple `uptime` executable that prints uptime in seconds.

## Cross-compiling for macOS with hermetic LLVM

Build the Apple silicon C, C++, and Swift binaries on Buildbarn's Linux workers and download them locally:

```sh
bazel build --config=remote_macos_llvm --remote_download_outputs=toplevel \
  //src/c:uptime //src/cpp:uptime //src/swift:uptime
```

Hermetic LLVM supplies Clang and the macOS SDK, and the Swift.org Linux toolchain supplies `swiftc`. The iOS app still uses Xcode through `--config=remote_macos`.
