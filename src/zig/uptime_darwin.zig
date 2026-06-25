const std = @import("std");
const posix = std.posix;

const ctl_kern: c_int = 1;
const kern_boottime: c_int = 21;

pub fn main() !void {
    var boottime: posix.timeval = undefined;
    var size: usize = @sizeOf(posix.timeval);
    const mib = [_]c_int{ ctl_kern, kern_boottime };

    posix.sysctl(&mib, &boottime, &size, null, 0) catch {
        std.log.err("Failed to get system uptime", .{});
        return;
    };

    var now: posix.timespec = undefined;
    switch (posix.errno(posix.system.clock_gettime(.REALTIME, &now))) {
        .SUCCESS => {},
        else => {
            std.log.err("Failed to get current time", .{});
            return;
        },
    }

    const uptime = now.sec - boottime.sec;
    std.debug.print("{}\n", .{uptime});
}
