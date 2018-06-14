@testable import LetGoGodMode

final class MockAnalyticsSessionManager: AnalyticsSessionManager {
    var startOrContinueSessionCalled: Bool = false
    var pauseSessionCalled: Bool = false


    // MARK: - AnalyticsSessionManager

    var sessionThresholdReachedCompletion: (() -> Void)?

    func startOrContinueSession(visitStartDate: Date) {
        startOrContinueSessionCalled = true
    }

    func pauseSession(visitEndDate: Date) {
        pauseSessionCalled = true
    }
}
