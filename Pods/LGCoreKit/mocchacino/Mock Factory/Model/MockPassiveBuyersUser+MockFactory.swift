extension MockPassiveBuyersUser: MockFactory {
    public static func makeMock() -> MockPassiveBuyersUser {
        return MockPassiveBuyersUser(objectId: String.makeRandom(),
                                     name: String?.makeRandom(),
                                     avatar: MockFile?.makeMock())
    }
}
