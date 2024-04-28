const std = @import("std");

pub fn main() !void {
    var sysinfo: std.os.linux.sysinfo = undefined;
    try std.os.linux.sysinfo(&sysinfo);
    const uptime = sysinfo.uptime;
    std.debug.print("{}\n", .{uptime});
}
