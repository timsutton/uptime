import Foundation

@main
struct Main {
  static func main() {
    #if os(macOS)
      var boottime = timeval()
      var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
      var size = MemoryLayout<timeval>.stride

      sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
      let bootDate = Date(
        timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec)
          / 1_000_000)
      let uptimeInSeconds = Int(Date().timeIntervalSince(bootDate))
    #endif

    #if os(Linux)
      var ts = timespec()
      clock_gettime(CLOCK_BOOTTIME, &ts)
      let uptimeInSeconds = ts.tv_sec
    #endif

    print(uptimeInSeconds)
  }
}
