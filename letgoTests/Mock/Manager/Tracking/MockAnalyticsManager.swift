@testable import LetGoGodMode

class MockAnalyticsSessionManager: AnalyticsSessionManager {
    var startOrContinueSessionCalled: Bool = false
    var pauseSessionCalled: Bool = false


    // MARK: - AnalyticsSessionManager

    var sessionThresholdReachedCompletion: (() -> Void)?

    func startOrContinueSession(timestamp: TimeInterval) {
        startOrContinueSessionCalled = true
    }

    func pauseSession(timestamp: TimeInterval) {
        pauseSessionCalled = true
    }
}
