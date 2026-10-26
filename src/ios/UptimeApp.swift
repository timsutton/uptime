import SwiftUI

/// Seconds since boot, including time spent asleep. `ProcessInfo.systemUptime`
/// doesn't count sleep, which is most of the time on a locked iPhone.
func uptimeInSeconds() -> TimeInterval {
    var boottime = timeval()
    var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
    var size = MemoryLayout<timeval>.stride

    sysctl(&mib, u_int(mib.count), &boottime, &size, nil, 0)
    let bootDate = Date(
        timeIntervalSince1970: TimeInterval(boottime.tv_sec) + TimeInterval(boottime.tv_usec) / 1_000_000
    )
    return Date().timeIntervalSince(bootDate)
}

struct UptimeView: View {
    private let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { _ in
            let uptime = uptimeInSeconds()
            VStack(spacing: 8) {
                Text("Uptime")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(formatter.string(from: uptime) ?? "")
                    .font(.largeTitle.monospacedDigit())
                Text("\(Int(uptime)) seconds")
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@main
struct UptimeApp: App {
    var body: some Scene {
        WindowGroup {
            UptimeView()
        }
    }
}
