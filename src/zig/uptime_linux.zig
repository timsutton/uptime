const std = @import("std");
const c = @cImport({
    @cInclude("sys/sysinfo.h");
});

pub fn getSystemUptime() c_long {
    var info: c.struct_sysinfo = undefined;
    if (c.sysinfo(&info) == 0) return @as(c_long, info.uptime);
    return 0;
}

pub fn main() !void {
    const uptime = getSystemUptime();
    std.debug.print("{}\n", .{uptime});
}
