# uptime

Learning Bazel with a polyglot multi-platform project: a simple `uptime` executable that prints uptime in seconds.

## Cross-compiling for macOS with hermetic LLVM

Build the Apple silicon C and C++ binaries on Buildbarn's Linux workers and download them locally:

```sh
bazel build --config=remote_macos_llvm --remote_download_outputs=toplevel \
  //src/c:uptime //src/cpp:uptime
```

Hermetic LLVM downloads its own compiler and macOS SDK. The Swift CLI and iOS app still use Xcode through `--config=remote_macos`.
