import core.stdc.stdio : perror, printf;
import core.stdc.stdlib : EXIT_FAILURE, EXIT_SUCCESS;

version (OSX)
{
    import core.stdc.time : time, time_t;
    import core.sys.darwin.sys.sysctl : CTL_KERN, KERN_BOOTTIME, sysctl;
    import core.sys.posix.sys.time : timeval;

    int main()
    {
        timeval boottime;
        size_t len = boottime.sizeof;
        int[2] mib = [CTL_KERN, KERN_BOOTTIME]; // MIB for kern.boottime

        // Retrieve the boottime
        if (sysctl(mib.ptr, cast(uint) mib.length, &boottime, &len, null, 0) < 0)
        {
            perror("sysctl");
            return EXIT_FAILURE;
        }

        const time_t now = time(null);
        printf("%ld\n", cast(long)(now - boottime.tv_sec));
        return EXIT_SUCCESS;
    }
}
else version (linux)
{
    import core.sys.linux.sys.sysinfo : sysinfo, sysinfo_;

    int main()
    {
        sysinfo_ info;
        if (sysinfo(&info) != 0)
        {
            perror("sysinfo");
            return EXIT_FAILURE;
        }

        printf("%ld\n", cast(long) info.uptime);
        return EXIT_SUCCESS;
    }
}
else
{
    static assert(0, "Unsupported platform");
}
