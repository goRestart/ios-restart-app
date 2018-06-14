import Foundation

protocol AnalyticsSessionDAO {
    func retrieveSessionData() -> AnalyticsSessionData?
    func save(sessionData: AnalyticsSessionData)
}

final class AnalyticsSessionUDDAO: AnalyticsSessionDAO {
    private let keyValueStorage: KeyValueStorageable
    private var sessionData: AnalyticsSessionData?


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
        self.sessionData = keyValueStorage.analyticsSessionData
    }


    // MARK: - AnalyticsSessionDAO

    func retrieveSessionData() -> AnalyticsSessionData? {
        return sessionData
    }

    func save(sessionData: AnalyticsSessionData) {
        self.sessionData = sessionData
        keyValueStorage.analyticsSessionData = sessionData
    }
}
