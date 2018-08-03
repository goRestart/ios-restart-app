extension MockNotificationGroupSetting: MockFactory {
    public static func makeMock() -> MockNotificationGroupSetting {
        return MockNotificationGroupSetting(objectId: String.makeRandom(),
                                            name: String.makeRandom(),
                                            description: String.makeRandom(),
                                            isEnabled: Bool.makeRandom())
    }
}

