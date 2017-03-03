import Foundation

extension TimeZone: Randomizable {
    public static func makeRandom() -> TimeZone {
        let identifier = knownTimeZoneIdentifiers.random()!
        return self.init(identifier: identifier)!
    }
}
