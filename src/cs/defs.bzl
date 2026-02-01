"""Custom rule for publishing a single-file .NET binary."""

def _dirname(path):
    idx = path.rfind("/")
    if idx == -1:
        return "."
    return path[:idx]

def _dotnet_singlefile_binary_impl(ctx):
    toolchain = ctx.toolchains["@rules_dotnet//dotnet:toolchain_type"]
    dotnet = toolchain.runtime.files_to_run.executable

    publish_dir = ctx.actions.declare_directory(ctx.label.name + "_publish")
    intermediate_dir = ctx.actions.declare_directory(ctx.label.name + "_intermediate")
    output = ctx.actions.declare_file(ctx.label.name)

    assembly_name = ctx.attr.assembly_name
    if not assembly_name:
        assembly_name = ctx.label.name

    runtime_files = toolchain.runtime[DefaultInfo].files

    publish_cmd = """\
set -euo pipefail
DOTNET_ROOT="$(pwd)/{dotnet_root}"
export DOTNET_ROOT
export DOTNET_MULTILEVEL_LOOKUP=0
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_CLI_HOME="$(pwd)/{intermediate}/.dotnet"
export NUGET_PACKAGES="$(pwd)/{intermediate}/.nuget"

"{dotnet}" publish "{project}" \
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
        inputs = depset([ctx.file.project] + ctx.files.srcs, transitive = [runtime_files]),
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
        "runtime_identifier": attr.string(mandatory = True),
        "configuration": attr.string(default = "Release"),
        "assembly_name": attr.string(default = ""),
        "publish_single_file": attr.bool(default = True),
        "self_contained": attr.bool(default = True),
    },
    toolchains = ["@rules_dotnet//dotnet:toolchain_type"],
)
