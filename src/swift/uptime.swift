import Foundation

@main
struct Main {
    static func main() {
        var boottime = timeval()
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        var size = MemoryLayout<timeval>.stride

        let result = sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
        if result != -1 {
            let bootDate = Date(
                timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec) / 1_000_000)
            let uptimeInSeconds = Int(Date().timeIntervalSince(bootDate))
            print(uptimeInSeconds) // Directly print the uptime in seconds
        } else {
            print("Failed to fetch system uptime")
            exit(1)
        }
    }
}
