const std = @import("std");
const c = @cImport({
    @cInclude("sys/sysinfo.h");
});

pub fn getSystemUptime() u64 {
    var info: c.struct_sysinfo = undefined;
    if (c.sysinfo(&info) == 0) return @as(u64, info.uptime);
    return 0;
}

pub fn main() !void {
    const uptime = getSystemUptime();
    std.debug.print("{}\n", .{uptime});
}
