extension MockUnreadNotificationsCounts: MockFactory {
    public static func makeMock() -> MockUnreadNotificationsCounts {
        return MockUnreadNotificationsCounts(modular: Int.makeRandom(),
                                             total: Int.makeRandom())
    }
}
