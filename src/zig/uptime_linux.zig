const std = @import("std");
const linux = std.os.linux;

pub fn getSystemUptime() isize {
    var info: linux.Sysinfo = undefined;
    if (linux.errno(linux.sysinfo(&info)) == .SUCCESS) return info.uptime;
    return 0;
}

pub fn main() !void {
    const uptime = getSystemUptime();
    std.debug.print("{}\n", .{uptime});
}
