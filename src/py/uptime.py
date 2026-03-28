#!/usr/bin/env python

import ctypes
import platform
from ctypes import Structure, byref, c_int32, c_long, c_size_t, sizeof, util

# Load the libc library
libc = ctypes.CDLL(util.find_library("c"))


class timeval(Structure):
    _fields_ = [
        ("tv_sec", c_long),
        ("tv_usec", c_int32),
    ]


def get_system_uptime_darwin():
    sysctlbyname = libc.sysctlbyname
    sysctlbyname.argtypes = [
        ctypes.c_char_p,
        ctypes.c_void_p,
        ctypes.POINTER(c_size_t),
        ctypes.c_void_p,
        c_size_t,
    ]
    sysctlbyname.restype = ctypes.c_int

    libc.time.argtypes = [ctypes.c_void_p]
    libc.time.restype = c_long

    # Create an instance of timeval
    tv = timeval()
    # The size of the timeval structure
    size = c_size_t(sizeof(tv))

    # Get the system uptime using sysctlbyname
    result = sysctlbyname(b"kern.boottime", byref(tv), byref(size), None, 0)

    if result != 0:
        # If there is an error (non-zero result), raise an exception
        raise OSError(ctypes.get_errno(), "Failed to get uptime")

    # Calculate uptime in seconds (ignoring microseconds)
    # Get current time in seconds
    current_time = libc.time(None)
    # Uptime is current time minus the boot time
    uptime_seconds = current_time - tv.tv_sec
    return uptime_seconds


def main():
    system = platform.uname().system
    if system == "Linux":
        with open("/proc/uptime", "r") as f:
            uptime_seconds = int(float(f.readline().split()[0]))
            print(uptime_seconds)
        return

    if system == "Darwin":
        print(get_system_uptime_darwin())
        return

    raise NotImplementedError(f"unsupported platform: {system}")


if __name__ == "__main__":
    main()
