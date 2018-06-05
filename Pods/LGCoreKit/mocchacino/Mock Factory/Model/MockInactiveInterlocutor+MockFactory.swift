extension MockInactiveInterlocutor: MockFactory {
    public static func makeMock() -> MockInactiveInterlocutor {
        return MockInactiveInterlocutor(objectId: String.makeRandom(),
                                        name: String.makeRandom(),
                                        avatar: MockFile?.makeMock(),
                                        status: UserStatus.makeMock(),
                                        lastConnectedAt: Date.makeRandom(),
                                        lastUpdatedAt: Date.makeRandom())
    }
}
