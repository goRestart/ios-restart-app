import Foundation

extension TimeInterval {
    public static func make(minutes: Int) -> TimeInterval {
        return 60 * TimeInterval(minutes)
    }
    public static func make(hours: Int) -> TimeInterval {
        return 60 * 60 * TimeInterval(hours)
    }
    public static func make(days: Int) -> TimeInterval {
        return 60 * 60 * 24 * TimeInterval(days)
    }
}
