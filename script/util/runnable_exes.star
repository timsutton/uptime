def format(target):
    # This currently results in a lot of:
    # Error: 'NoneType' value has no field or method 'path'
    #
    # TODO: improve this Starlark so that we can filter out the non-applicable targets for this
    #       query before we try and access any executable-related attributes
    if target.files_to_run.executable.path.endswith("uptime") and "py" not in str(target.label):
        return target.files_to_run.executable.path
    else:
        return ""
