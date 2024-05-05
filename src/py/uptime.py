#!/usr/bin/env python

import platform
import sys

import ctypes
from ctypes import util, Structure, c_uint, c_ulonglong, sizeof, byref

# Load the libc library
libc = ctypes.CDLL(util.find_library('c'))

# Define the structure for timeval (used to store the uptime)


class timeval(Structure):
    _fields_ = [("tv_sec", c_ulonglong),  # seconds
                ("tv_usec", c_ulonglong)]  # microseconds


def get_system_uptime_darwin():
    # Create an instance of timeval
    tv = timeval()
    # The size of the timeval structure
    size = c_uint(sizeof(tv))

    # Get the system uptime using sysctlbyname
    result = libc.sysctlbyname(
        b"kern.boottime", byref(tv), byref(size), None, 0)

    if result != 0:
        # If there is an error (non-zero result), raise an exception
        raise OSError(ctypes.get_errno(), "Failed to get uptime")

    # Calculate uptime in seconds (ignoring microseconds)
    # Get current time in seconds
    current_time = libc.time(None)
    # Uptime is current time minus the boot time
    uptime_seconds = current_time - tv.tv_sec
    return uptime_seconds


system = platform.uname().system
if system == "Linux":
    with open('/proc/uptime', 'r') as f:
        uptime_seconds = int(float(f.readline().split()[0]))
        print(uptime_seconds)
    sys.exit()

if system == "Darwin":
    print(get_system_uptime_darwin())
