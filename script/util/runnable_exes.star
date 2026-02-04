def format(target):
    # This currently results in a lot of:
    # Error: 'NoneType' value has no field or method 'path'
    #
    # TODO: improve this Starlark so that we can filter out the non-applicable targets for this
    #       query before we try and access any executable-related attributes
    exe = target.files_to_run.executable
    if exe == None:
        return ""
    if "py" in str(target.label):
        return ""
    if exe.path.endswith("uptime") or exe.path.endswith("uptime_aot"):
        return exe.path
    return ""
