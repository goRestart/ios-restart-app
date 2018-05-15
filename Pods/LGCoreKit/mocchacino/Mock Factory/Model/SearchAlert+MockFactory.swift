extension MockSearchAlert: MockFactory {
    public static func makeMock() -> MockSearchAlert {
        return MockSearchAlert(objectId: String.makeRandom(),
                               query: String.makeRandom(),
                               enabled: Bool.makeRandom(),
                               createdAt: Date().roundedMillisecondsSince1970())
    }
}
