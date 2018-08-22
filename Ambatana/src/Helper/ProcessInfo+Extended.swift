import Foundation

extension ProcessInfo {
    func isIOSVersionInRange(from: OperatingSystemVersion, to: OperatingSystemVersion) -> Bool {
        guard ProcessInfo().isOperatingSystemAtLeast(from) else {
            return false
        }
        guard !ProcessInfo().isOperatingSystemAtLeast(to) else {
            return false
        }
        return true
    }
}
