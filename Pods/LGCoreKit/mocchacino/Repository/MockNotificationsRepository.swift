import Result

open class MockNotificationsRepository: NotificationsRepository {
    public var indexResult: NotificationsResult
    public var unreadCountResult: NotificationsUnreadCountResult


    // MARK: - Lifecycle

    public init() {
        self.indexResult = NotificationsResult(value: MockNotificationModel.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        self.unreadCountResult = NotificationsUnreadCountResult(value: MockUnreadNotificationsCounts.makeMock())
    }


    // MARK: - NotificationsRepository

    public func index(_ completion: NotificationsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func unreadNotificationsCount(_ completion: NotificationsUnreadCountCompletion?) {
        delay(result: unreadCountResult, completion: completion)
    }
}
