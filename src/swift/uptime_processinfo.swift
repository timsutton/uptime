import Foundation

@main
enum Main {
    static func main() {
        let uptime = Int(ProcessInfo.processInfo.systemUptime)
        print("\(uptime)")
    }
}
