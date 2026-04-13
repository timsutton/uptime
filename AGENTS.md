# AGENTS.md

## Repo layout

- Language-specific targets live under `//src/<lang>`.
- When adding or changing an implementation, look in the matching `src/<lang>` directory first.

## Required checks

- If you change source files or any Bazel/Starlark files, run `bazel run //tools/format:format.check` before finishing.
- If formatting changes are needed, run `bazel run //tools/format:format`.
- Treat this as required for changes under `src/**`, `BUILD*`, `*.bzl`, and `MODULE.bazel`.

## Branch workflow

- When creating a branch for a new change, open a pull request immediately and keep the work attached to that PR.
