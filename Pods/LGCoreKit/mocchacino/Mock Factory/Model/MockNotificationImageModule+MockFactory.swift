
extension MockNotificationImageModule: MockFactory {
    public static func makeMock() -> MockNotificationImageModule {
        let allValues: [NotificationImageShape] = [.circle, .square]
        return MockNotificationImageModule(shape: allValues.random() , imageURL: String.makeRandomURL(), deeplink: String.makeRandom())
    }
}
