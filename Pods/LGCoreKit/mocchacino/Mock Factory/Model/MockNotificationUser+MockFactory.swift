extension MockNotificationUser: MockFactory {
    public static func makeMock() -> MockNotificationUser {
        return MockNotificationUser(id: String.makeRandom(),
                                    name: String?.makeRandom(),
                                    avatar: String.makeRandomURL())
    }
}
