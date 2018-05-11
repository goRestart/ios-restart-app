import Foundation

extension TimeInterval {
    static func make(minutes: Int) -> TimeInterval {
        return 60 * TimeInterval(minutes)
    }
    static func make(hours: Int) -> TimeInterval {
        return 60 * 60 * TimeInterval(hours)
    }
    static func make(days: Int) -> TimeInterval {
        return 60 * 60 * 24 * TimeInterval(days)
    }
}
