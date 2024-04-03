#!/usr/bin/env python

# hack that doesn't actually use sysctl natively at all – shells out to sysctl
# until we make this below module work or we do ctypes ourselves:
# uv pip install git+https://github.com/da4089/py-sysctl@3dadf5a4bc955a2eab3cea5a1f21143384a711f7

import subprocess
from datetime import datetime

now = datetime.now()
out, _ = subprocess.Popen(["/usr/sbin/sysctl", "-n", "kern.boottime"], stdout=subprocess.PIPE).communicate()

boottime_seconds = int(out.split()[3].decode().strip().strip(','))
boottime_time = datetime.fromtimestamp(boottime_seconds)

uptime_seconds = int((now - boottime_time).total_seconds())
print(uptime_seconds)
