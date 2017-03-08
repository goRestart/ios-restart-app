
extension MockNotificationTextModule: MockFactory {
    public static func makeMock() -> MockNotificationTextModule {
        return MockNotificationTextModule(title: String.makeRandom(), body: String.makeRandom(), deeplink: String.makeRandom())
    }
}




