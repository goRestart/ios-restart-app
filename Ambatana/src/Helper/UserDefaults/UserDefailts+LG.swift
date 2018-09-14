import Foundation

extension UserDefaults {
    static var letgo: UserDefaults {
        let suiteName = "group.letgo"
        return UserDefaults(suiteName: suiteName) ?? UserDefaults()
    }
}
