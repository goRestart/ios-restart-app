import Foundation

extension Date: Randomizable {
    public static func makeRandom() -> Date {
        let hour = Double(Int.makeRandom(min: 0, max: 86400) * 1000)   // +/- 1 hour
        return Date(timeIntervalSinceNow: Double.makeRandom(min: -hour, max: hour))
    }
}
