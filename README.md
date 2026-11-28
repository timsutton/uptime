# uptime

Learning Bazel with a polyglot multi-platform project: a simple `uptime` executable that prints uptime in seconds.

## Hermetic LLVM on the macOS worker

To try hermetic LLVM for the C and C++ binaries on the Buildbarn Mac worker, run:

```sh
bazel build --config=remote_macos_llvm //src/c:uptime //src/cpp:uptime
```

The toolchain downloads its own compiler and macOS SDK. Use `--config=remote_macos` for builds that need Xcode, such as the Swift CLI or iOS app.
