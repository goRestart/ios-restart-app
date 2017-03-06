
extension MockNotificationTextModule: MockFactory {
    public static func makeMock() -> MockNotificationTextModule {
        return MockNotificationTextModule(title: String.makeRandom(), body: String.makeRandom(), deeplink: String.makeRandom())
    }
}

extension MockNotificationImageModule: MockFactory {
    public static func makeMock() -> MockNotificationImageModule {
        let allValues: [ImageShape] = [.circle, .square]
        return MockNotificationImageModule(shape: allValues.random() , imageURL: String.makeRandomURL(), deeplink: String.makeRandom())
    }
}

extension MockNotificationCTAModule: MockFactory {
    public static func makeMock() -> MockNotificationCTAModule {
        return MockNotificationCTAModule(title: String.makeRandom(), deeplink: String.makeRandom())
    }
}



