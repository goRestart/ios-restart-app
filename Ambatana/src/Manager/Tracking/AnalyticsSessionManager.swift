protocol AnalyticsSessionManager {
    var sessionThresholdReachedCompletion: (() -> Void)? { get set }
    func startOrContinueSession(timestamp: TimeInterval)
    func pauseSession(timestamp: TimeInterval)
}

class LGAnalyticsSessionManager: AnalyticsSessionManager {
    var sessionThresholdReachedCompletion: (() -> Void)?
    func startOrContinueSession(timestamp: TimeInterval) {}
    func pauseSession(timestamp: TimeInterval) {}
}
