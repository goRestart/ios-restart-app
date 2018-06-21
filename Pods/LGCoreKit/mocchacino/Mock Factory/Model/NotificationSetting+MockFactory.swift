extension MockNotificationSetting: MockFactory {
    public static func makeMock() -> MockNotificationSetting {
        return MockNotificationSetting(objectId: String.makeRandom(),
                                       name: String.makeRandom(),
                                       groupSettings: MockNotificationGroupSetting.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
