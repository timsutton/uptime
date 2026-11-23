def format(target):
    # Filter out targets that can't produce a runnable executable before accessing any
    # executable-related attributes (files_to_run is None for non-executable targets).
    if target.files_to_run == None:
        return ""
    exe = target.files_to_run.executable
    if exe == None:
        return ""
    if "py" in str(target.label):
        return ""
    if exe.path.endswith("uptime") or exe.path.endswith("uptime_aot"):
        return exe.path
    return ""
