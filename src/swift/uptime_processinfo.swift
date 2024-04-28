import Foundation

@main
struct Main {
  static func main() {

    let uptime = Int(ProcessInfo.processInfo.systemUptime)
    print("\(uptime)")
  }
}
