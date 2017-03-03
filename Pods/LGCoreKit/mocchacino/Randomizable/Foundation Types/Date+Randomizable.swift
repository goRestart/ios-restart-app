import Foundation

extension Date: Randomizable {
    public static func makeRandom() -> Date {
        return Date(timeIntervalSinceNow: Double.makeRandom())
    }
}
