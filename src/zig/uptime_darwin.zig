const std = @import("std");
const c = std.c;

const Timeval = extern struct {
    tv_sec: i64,  // time_t
    tv_usec: i32, // suseconds_t
};

pub fn main() !void {
    var boottime: c.timeval = undefined;
    var size: usize = @sizeOf(c.timeval);

    if (c.sysctlbyname("kern.boottime", &boottime, &size, null, 0) != 0) {
        std.log.err("Failed to get system uptime", .{});
        return;
    }

    const now = std.time.timestamp();
    const bt_ptr: *const Timeval = @ptrCast(&boottime);

    const uptime = now - bt_ptr.tv_sec;
    std.debug.print("{}\n", .{uptime});
}