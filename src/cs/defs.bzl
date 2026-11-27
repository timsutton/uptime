"""Custom rules for publishing .NET binaries."""

def _dirname(path):
    idx = path.rfind("/")
    if idx == -1:
        return "."
    return path[:idx]

def _sdk_files(toolchain):
    """The `dotnet` executable plus the SDK and runtime files it loads, which are runfiles."""
    info = toolchain.runtime[DefaultInfo]
    return depset(transitive = [info.files, info.default_runfiles.files])

def _nuget_feed(ctx):
    """Shell commands and `dotnet publish` flags to restore only from `nuget_packages`.

    Without any, NuGet downloads the packages from nuget.org while publishing.
    """
    if not ctx.files.nuget_packages:
        return "", ""

    # Without network access, NuGet's signature check (certificate revocation)
    # and vulnerability audit stall until they time out. The packages are already
    # pinned by checksum.
    setup = 'export DOTNET_NUGET_SIGNATURE_VERIFICATION=false\nfeed="$(mktemp -d)"\ncp {} "$feed"'.format(
        " ".join(['"{}"'.format(f.path) for f in ctx.files.nuget_packages]),
    )
    return setup, '-p:RestoreSources="$feed" -p:NuGetAudit=false'

def _dotnet_singlefile_binary_impl(ctx):
    toolchain = ctx.toolchains["@rules_dotnet//dotnet:toolchain_type"]
    dotnet = toolchain.runtime.files_to_run.executable

    publish_dir = ctx.actions.declare_directory(ctx.label.name + "_publish")
    intermediate_dir = ctx.actions.declare_directory(ctx.label.name + "_intermediate")
    output = ctx.actions.declare_file(ctx.label.name)

    assembly_name = ctx.attr.assembly_name
    if not assembly_name:
        assembly_name = ctx.label.name

    runtime_files = _sdk_files(toolchain)
    feed_setup, feed_flag = _nuget_feed(ctx)

    publish_cmd = """\
set -euo pipefail
DOTNET_ROOT="$(pwd)/{dotnet_root}"
export DOTNET_ROOT
export PATH="/usr/bin:/bin:/usr/sbin:${{PATH:-}}"
export DOTNET_MULTILEVEL_LOOKUP=0
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_CLI_HOME="$(pwd)/{intermediate}/.dotnet"
# Remote workers don't set HOME, which NuGet requires.
export HOME="$DOTNET_CLI_HOME"
export NUGET_PACKAGES="$(pwd)/{intermediate}/.nuget"
{feed_setup}

"{dotnet}" publish "{project}" {feed_flag} \
  -c "{config}" \
  -r "{rid}" \
  -p:AssemblyName="{assembly_name}" \
  -p:PublishSingleFile={publish_single_file} \
  -p:SelfContained={self_contained} \
  -p:PublishTrimmed=false \
  -p:DebugType=None \
  -p:DebugSymbols=false \
  -p:BaseIntermediateOutputPath="$(pwd)/{intermediate}/obj/" \
  -p:BaseOutputPath="$(pwd)/{intermediate}/bin/" \
  -o "$(pwd)/{publish_dir}"
""".format(
        dotnet_root = _dirname(dotnet.path),
        dotnet = dotnet.path,
        feed_setup = feed_setup,
        feed_flag = feed_flag,
        project = ctx.file.project.path,
        config = ctx.attr.configuration,
        rid = ctx.attr.runtime_identifier,
        assembly_name = assembly_name,
        publish_single_file = "true" if ctx.attr.publish_single_file else "false",
        self_contained = "true" if ctx.attr.self_contained else "false",
        intermediate = intermediate_dir.path,
        publish_dir = publish_dir.path,
    )

    ctx.actions.run_shell(
        inputs = depset(
            [ctx.file.project] + ctx.files.srcs + ctx.files.nuget_packages,
            transitive = [runtime_files],
        ),
        outputs = [publish_dir, intermediate_dir],
        tools = [dotnet],
        command = publish_cmd,
        progress_message = "Publishing {} with dotnet".format(ctx.label),
    )

    ctx.actions.run_shell(
        inputs = [publish_dir],
        outputs = [output],
        command = "cp {src} {dst} && chmod +x {dst}".format(
            src = publish_dir.path + "/" + assembly_name,
            dst = output.path,
        ),
    )

    return DefaultInfo(
        executable = output,
        files = depset([output]),
        runfiles = ctx.runfiles(files = [output]),
    )

def _dotnet_nativeaot_binary_impl(ctx):
    toolchain = ctx.toolchains["@rules_dotnet//dotnet:toolchain_type"]
    dotnet = toolchain.runtime.files_to_run.executable

    publish_dir = ctx.actions.declare_directory(ctx.label.name + "_publish")
    intermediate_dir = ctx.actions.declare_directory(ctx.label.name + "_intermediate")
    output = ctx.actions.declare_file(ctx.label.name)

    assembly_name = ctx.attr.assembly_name
    if not assembly_name:
        assembly_name = ctx.label.name

    runtime_files = _sdk_files(toolchain)
    feed_setup, feed_flag = _nuget_feed(ctx)

    publish_cmd = """\
set -euo pipefail
DOTNET_ROOT="$(pwd)/{dotnet_root}"
export DOTNET_ROOT
export PATH="/usr/bin:/bin:/usr/sbin:${{PATH:-}}"
export DOTNET_MULTILEVEL_LOOKUP=0
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_CLI_HOME="$(pwd)/{intermediate}/.dotnet"
# Remote workers don't set HOME, which NuGet requires.
export HOME="$DOTNET_CLI_HOME"
export NUGET_PACKAGES="$(pwd)/{intermediate}/.nuget"
{feed_setup}

"{dotnet}" publish "{project}" {feed_flag} \
  -c "{config}" \
  -r "{rid}" \
  -p:AssemblyName="{assembly_name}" \
  -p:PublishAot=true \
  -p:SelfContained={self_contained} \
  -p:DebugType=None \
  -p:DebugSymbols=false \
  -p:BaseIntermediateOutputPath="$(pwd)/{intermediate}/obj/" \
  -p:BaseOutputPath="$(pwd)/{intermediate}/bin/" \
  -o "$(pwd)/{publish_dir}"
""".format(
        dotnet_root = _dirname(dotnet.path),
        dotnet = dotnet.path,
        feed_setup = feed_setup,
        feed_flag = feed_flag,
        project = ctx.file.project.path,
        config = ctx.attr.configuration,
        rid = ctx.attr.runtime_identifier,
        assembly_name = assembly_name,
        self_contained = "true" if ctx.attr.self_contained else "false",
        intermediate = intermediate_dir.path,
        publish_dir = publish_dir.path,
    )

    ctx.actions.run_shell(
        inputs = depset(
            [ctx.file.project] + ctx.files.srcs + ctx.files.nuget_packages,
            transitive = [runtime_files],
        ),
        outputs = [publish_dir, intermediate_dir],
        tools = [dotnet],
        command = publish_cmd,
        progress_message = "Publishing {} with dotnet (NativeAOT)".format(ctx.label),
    )

    ctx.actions.run_shell(
        inputs = [publish_dir],
        outputs = [output],
        command = "cp {src} {dst} && chmod +x {dst}".format(
            src = publish_dir.path + "/" + assembly_name,
            dst = output.path,
        ),
    )

    return DefaultInfo(
        executable = output,
        files = depset([output]),
        runfiles = ctx.runfiles(files = [output]),
    )

dotnet_singlefile_binary = rule(
    implementation = _dotnet_singlefile_binary_impl,
    executable = True,
    attrs = {
        "project": attr.label(
            mandatory = True,
            allow_single_file = [".csproj"],
        ),
        "srcs": attr.label_list(
            allow_files = [".cs"],
        ),
        "nuget_packages": attr.label_list(allow_files = [".nupkg"]),
        "runtime_identifier": attr.string(mandatory = True),
        "configuration": attr.string(default = "Release"),
        "assembly_name": attr.string(default = ""),
        "publish_single_file": attr.bool(default = True),
        "self_contained": attr.bool(default = True),
    },
    toolchains = ["@rules_dotnet//dotnet:toolchain_type"],
)

dotnet_nativeaot_binary = rule(
    implementation = _dotnet_nativeaot_binary_impl,
    executable = True,
    attrs = {
        "project": attr.label(
            mandatory = True,
            allow_single_file = [".csproj"],
        ),
        "srcs": attr.label_list(
            allow_files = [".cs"],
        ),
        "nuget_packages": attr.label_list(allow_files = [".nupkg"]),
        "runtime_identifier": attr.string(mandatory = True),
        "configuration": attr.string(default = "Release"),
        "assembly_name": attr.string(default = ""),
        "self_contained": attr.bool(default = True),
    },
    toolchains = ["@rules_dotnet//dotnet:toolchain_type"],
)
