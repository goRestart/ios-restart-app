
extension MockNotificationCTAModule: MockFactory {
    public static func makeMock() -> MockNotificationCTAModule {
        return MockNotificationCTAModule(title: String.makeRandom(), deeplink: String.makeRandom())
    }
}
