 
extension MockNotificationsRepository: MockFactory {
    public static func makeMock() -> Self {
        let mockNotificationsRepository = self.init()
        mockNotificationsRepository.indexResult = NotificationsResult(value: MockNotificationModel.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
        mockNotificationsRepository.unreadCountResult = NotificationsUnreadCountResult(value: MockUnreadNotificationsCounts.makeMock())
        return mockNotificationsRepository
    }
}
