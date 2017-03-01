extension MockNotificationProduct: MockFactory {
    public static func makeMock() -> MockNotificationProduct {
        return MockNotificationProduct(id: String.makeRandom(),
                                       title: String?.makeRandom(),
                                       image: String.makeRandomURL())
    }
}
