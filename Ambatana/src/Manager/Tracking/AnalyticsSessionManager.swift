import LGCoreKit

protocol AnalyticsSessionManager {
    var sessionThresholdReachedCompletion: (() -> Void)? { get set }
    func startOrContinueSession(visitStartDate: Date)
    func pauseSession(visitEndDate: Date)
}

class LGAnalyticsSessionManager: AnalyticsSessionManager {
    static let daysAfterRegistration: Int = 7

    private let minTimeBetweenSessions: TimeInterval
    private let sessionThreshold: TimeInterval
    private let myUserRepository: MyUserRepository
    private let dao: AnalyticsSessionDAO

    private var visitStartDate: Date?

    private var timer: Timer
    private var isSessionStarted: Bool


    // MARK: - Lifecycle

    init(minTimeBetweenSessions: TimeInterval,
         sessionThreshold: TimeInterval,
         myUserRepository: MyUserRepository,
         dao: AnalyticsSessionDAO) {
        self.minTimeBetweenSessions = minTimeBetweenSessions
        self.sessionThreshold = sessionThreshold
        self.myUserRepository = myUserRepository
        self.dao = dao
        self.timer = Timer()
        self.isSessionStarted = false
    }


    // MARK: - AnalyticsSessionManager

    var sessionThresholdReachedCompletion: (() -> Void)?

    func startOrContinueSession(visitStartDate: Date) {
        guard !isSessionStarted && didUserRegisterRecently() else { return }
        isSessionStarted = true

        if let sessionData = fetchSessionData(),
            visitStartDate.timeIntervalSinceNow - sessionData.lastVisitEndDate.timeIntervalSinceNow < minTimeBetweenSessions {
            resumeSession(sessionData: sessionData,
                          newVisitStartDate: visitStartDate)
        } else {
            startSession(visitStartDate: visitStartDate)
        }
    }

    func pauseSession(visitEndDate: Date) {
        guard let visitStartDate = visitStartDate, isSessionStarted else { return }
        isSessionStarted = false

        timer.invalidate()

        let updatedSessionData: AnalyticsSessionData
        if let sessionData = fetchSessionData() {
            updatedSessionData = sessionData.updating(visitStartDate: visitStartDate,
                                                      visitEndDate: visitEndDate)
        } else {
            updatedSessionData = AnalyticsSessionData.make(visitStartDate: visitStartDate,
                                                           visitEndDate: visitEndDate)
        }
        storeSessionData(sessionData: updatedSessionData)
    }


    // MARK: - Session

    private func startSession(visitStartDate: Date) {
        self.visitStartDate = visitStartDate
        scheduleTimer(timeout: sessionThreshold)
    }

    private func resumeSession(sessionData: AnalyticsSessionData,
                               newVisitStartDate: Date) {
        self.visitStartDate = newVisitStartDate

        let timeout = sessionThreshold - sessionData.length
        guard timeout >= 0 else { return }

        scheduleTimer(timeout: timeout)
    }

    private func didUserRegisterRecently() -> Bool {
        guard let creationDate = myUserRepository.myUser?.creationDate else { return false }
        let today = Date()
        let daysAfterRegistration = TimeInterval.make(days: LGAnalyticsSessionManager.daysAfterRegistration)
        let trackingLimitDate = creationDate.addingTimeInterval(daysAfterRegistration)
        return today < trackingLimitDate
    }


    // MARK: - Timer

    private func scheduleTimer(timeout: TimeInterval) {
        timer = Timer.scheduledTimer(timeInterval: timeout,
                                     target: self,
                                     selector: (#selector(LGAnalyticsSessionManager.sessionDidReachThreshold)),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc private func sessionDidReachThreshold() {
        sessionThresholdReachedCompletion?()
    }


    // MARK: - Storage

    private func fetchSessionData() -> AnalyticsSessionData? {
        return dao.retrieveSessionData()
    }

    private func storeSessionData(sessionData: AnalyticsSessionData) {
        dao.save(sessionData: sessionData)
    }
}
