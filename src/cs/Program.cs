using System;
using System.Globalization;
using System.IO;
using System.Runtime.InteropServices;

internal static class Program
{
    private static int Main()
    {
        Console.WriteLine(GetUptimeSeconds());
        return 0;
    }

    private static long GetUptimeSeconds()
    {
        if (OperatingSystem.IsLinux())
        {
            return ReadLinuxUptimeSeconds();
        }

        if (OperatingSystem.IsMacOS())
        {
            return ReadDarwinUptimeSeconds();
        }

        return Environment.TickCount64 / 1000;
    }

    private static long ReadLinuxUptimeSeconds()
    {
        var contents = File.ReadAllText("/proc/uptime");
        var first = contents.Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries)[0];
        if (!double.TryParse(first, NumberStyles.Float, CultureInfo.InvariantCulture, out var seconds))
        {
            throw new InvalidOperationException("Failed to parse /proc/uptime.");
        }

        return (long)seconds;
    }

    private static long ReadDarwinUptimeSeconds()
    {
        var boottime = ReadDarwinBootTime();
        var now = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        return now - boottime.tv_sec;
    }

    private static Timeval ReadDarwinBootTime()
    {
        nuint size = (nuint)Marshal.SizeOf<Timeval>();
        IntPtr buffer = Marshal.AllocHGlobal((int)size);
        try
        {
            if (sysctlbyname("kern.boottime", buffer, ref size, IntPtr.Zero, 0) != 0)
            {
                throw new InvalidOperationException("sysctlbyname(\"kern.boottime\") failed.");
            }

            return Marshal.PtrToStructure<Timeval>(buffer);
        }
        finally
        {
            Marshal.FreeHGlobal(buffer);
        }
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct Timeval
    {
        public long tv_sec;
        public int tv_usec;
        public int tv_pad;
    }

    [DllImport("libc", SetLastError = true)]
    private static extern int sysctlbyname(
        string name,
        IntPtr oldp,
        ref nuint oldlenp,
        IntPtr newp,
        nuint newlen);
}
