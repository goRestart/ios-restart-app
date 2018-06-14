@testable import LetGoGodMode

final class MockAnalyticsSessionDAO: AnalyticsSessionDAO {
    var sessionData: AnalyticsSessionData?

    init() {
    }

    func retrieveSessionData() -> AnalyticsSessionData? {
        return sessionData
    }

    func save(sessionData: AnalyticsSessionData) {
        self.sessionData = sessionData
    }
}
