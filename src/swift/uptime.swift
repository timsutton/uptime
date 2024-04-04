import Foundation

func fetchAndPrintSystemUptimeInSeconds() {
    var boottime = timeval()
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME] // Management Information Base (MIB)
    var size = MemoryLayout<timeval>.stride

    let result = sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
    if result != -1 {
        let bootDate = Date(
            timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec) / 1_000_000)
        let uptimeInSeconds = Int(Date().timeIntervalSince(bootDate))
        print(uptimeInSeconds) // Directly print the uptime in seconds
    } else {
        print("Failed to fetch system uptime")
    }
}

// Call the function to print the system uptime in seconds
fetchAndPrintSystemUptimeInSeconds()
