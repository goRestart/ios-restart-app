import Foundation

extension Locale: Randomizable {
    public static func makeRandom() -> Locale {
        let identifier = Locale.availableIdentifiers.random()!
        return self.init(identifier: identifier)
    }
}
