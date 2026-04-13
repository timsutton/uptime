# Kotlin GraalVM Notes

This target uses OSHI inside a GraalVM native image, which means it also pulls in JNA and needs explicit native-image metadata.

## Why these config files exist

The native image currently depends on these metadata files:

- `jna-reflection-config.json`
- `jna-jni-config.json`
- `jna-proxy-config.json`

They exist because OSHI and JNA do work dynamically at runtime:

- reflection on classes, fields, and constructors
- JNI access
- `Proxy` generation for JNA `Library` interfaces
- loading bundled native resources from the JNA jars

Without that metadata, the native image builds but fails at runtime with errors like:

- `MissingReflectionRegistrationError`
- missing dynamic proxy metadata
- missing JNA resources
- missing constructor/field reflection metadata
- missing charset support

## How these files were derived

These files were not written from scratch blindly. They came from a combination of:

1. GraalVM's official reachability metadata
2. Iteration from actual native-image runtime failures
3. Bytecode inspection of OSHI/JNA classes

### 1. Official reachability metadata

The initial seed came from the GraalVM reachability metadata repository:

- <https://github.com/oracle/graalvm-reachability-metadata>

In particular, the JNA metadata there was used as a starting point. That repository uses the newer combined `reachability-metadata.json` format, while this Bazel setup passes separate config files to `native-image`, so the JNA metadata had to be translated into split files like:

- `reflect-config.json`
- `jni-config.json`
- `proxy-config.json`

### 2. Iteration from runtime errors

After wiring OSHI into the Kotlin target, the native image was built and executed repeatedly. Each failure identified the next missing piece of metadata. Examples that came up while getting this target working:

- JNA native resources were not included
- reflection metadata was missing for JNA structure classes and helper classes
- dynamic proxy metadata was missing for JNA interfaces on macOS and Linux
- additional charsets were required because OSHI references `Windows-1252`

The CI failures were also useful here. For example, Linux runners later reported a missing proxy registration for `com.sun.jna.platform.linux.Udev`, which was then added to `jna-proxy-config.json`.

### 3. Inspecting classes directly

For classes named in the failures, `javap` was used against the resolved `oshi`, `jna`, and `jna-platform` jars to confirm things like:

- whether a type was a JNA `Library` interface and therefore needed proxy metadata
- whether a class had a public no-arg constructor
- which nested helper classes existed

That made it possible to add targeted metadata instead of broad, unbounded config.

## How a person would do this by hand

If doing this manually, the usual workflow is:

1. Build the native image
2. Run it
3. Read the failure carefully
4. Add only the metadata the failure calls out
5. Rebuild and repeat

Typical categories:

- reflection config: classes, constructors, fields, methods
- JNI config: classes/methods/fields looked up from native code
- proxy config: exact interface lists for `Proxy` generation
- resource config: native resources or other files that must be embedded

This process is iterative. Native-image errors are often explicit enough to drive the next fix directly.

## Tooling that helps generate this metadata

The main GraalVM tool for this is the Native Image tracing agent.

You run the program on a regular JVM with the agent enabled:

```bash
java -agentlib:native-image-agent=config-output-dir=./native-image-config ...
```

It records dynamic behavior that actually occurs during the run and emits files such as:

- `reflect-config.json`
- `jni-config.json`
- `proxy-config.json`
- `resource-config.json`

You can also merge multiple runs with:

```bash
java -agentlib:native-image-agent=config-merge-dir=./native-image-config ...
```

This is the best first step for most applications.

Relevant docs:

- <https://www.graalvm.org/latest/reference-manual/native-image/metadata/AutomaticMetadataCollection/>
- <https://www.graalvm.org/jdk24/reference-manual/native-image/guides/configure-with-tracing-agent/>
- <https://www.graalvm.org/latest/reference-manual/native-image/metadata/>

## Important limitation of the tracing agent

The tracing agent only records code paths you actually execute.

That means:

- it is very useful
- it is not automatically complete

If you only exercise one OS path or one runtime branch, the generated metadata may still be missing entries for other platforms or code paths. That is why this target still required follow-up fixes after the first pass.

## Practical recommendation for this target

If this target changes again, the most practical workflow is:

1. Start from the existing metadata files in this directory
2. Run the JVM version with the tracing agent enabled
3. Exercise the target on both macOS and Linux if possible
4. Merge the generated output
5. Rebuild the native image
6. Use any remaining runtime errors to make targeted fixes

That should be much faster and safer than rebuilding all of this context from scratch.
