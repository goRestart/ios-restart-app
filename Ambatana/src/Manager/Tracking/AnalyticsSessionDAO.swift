import Foundation

protocol AnalyticsSessionDAO {
    func retrieveSessionData() -> AnalyticsSessionData?
    func save(sessionData: AnalyticsSessionData)
}

final class AnalyticsSessionUDDAO: AnalyticsSessionDAO {
    static let UserDefaultsKey = "AnalyticsSession"
    private let userDefaults: UserDefaults
    private var sessionData: AnalyticsSessionData?


    // MARK: - Lifecycle

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
        if let dictionary = userDefaults.dictionary(forKey: AnalyticsSessionUDDAO.UserDefaultsKey) {
            self.sessionData = AnalyticsSessionData.decode(dictionary)
        } else {
            self.sessionData = nil
        }
    }


    // MARK: - AnalyticsSessionDAO

    func retrieveSessionData() -> AnalyticsSessionData? {
        return sessionData
    }

    func save(sessionData: AnalyticsSessionData) {
        self.sessionData = sessionData
        let dict = sessionData.encode()
        userDefaults.setValue(dict, forKey: AnalyticsSessionUDDAO.UserDefaultsKey)
    }
}
