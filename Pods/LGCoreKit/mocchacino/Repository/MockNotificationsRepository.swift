import Result

open class MockNotificationsRepository: NotificationsRepository {
    public var indexResult: NotificationsResult!
    public var unreadCountResult: NotificationsUnreadCountResult!


    // MARK: - Lifecycle

    required public init() {

    }


    // MARK: - NotificationsRepository

    public func index(_ completion: NotificationsCompletion?) {
        delay(result: indexResult, completion: completion)
    }

    public func unreadNotificationsCount(_ completion: NotificationsUnreadCountCompletion?) {
        delay(result: unreadCountResult, completion: completion)
    }
}
