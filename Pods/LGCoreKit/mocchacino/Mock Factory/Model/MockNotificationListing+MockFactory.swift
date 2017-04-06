extension MockNotificationListing: MockFactory {
    public static func makeMock() -> MockNotificationListing {
        return MockNotificationListing(id: String.makeRandom(),
                                       title: String?.makeRandom(),
                                       image: String.makeRandomURL())
    }
}
