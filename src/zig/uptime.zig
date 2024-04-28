const std = @import("std");
const c = std.c;

pub fn main() !void {
    var boottime: c.timeval = undefined;
    var size: usize = @sizeOf(c.timeval);

    if (c.sysctlbyname("kern.boottime", &boottime, &size, null, 0) != 0) {
        std.log.err("Failed to get system uptime", .{});
        return;
    }

    const now = std.time.timestamp();
    const uptime = now - boottime.tv_sec;
    std.debug.print("{}\n", .{uptime});
}
