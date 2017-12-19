import Foundation

extension Locale: Randomizable {
    public static func makeRandom() -> Locale {
        let identifier = Locale.availableIdentifiers.random()!
        let validIdentifier = Locale(identifier: identifier).identifier
        return self.init(identifier: validIdentifier)
    }
}
