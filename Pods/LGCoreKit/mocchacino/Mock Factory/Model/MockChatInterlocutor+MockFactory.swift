extension MockChatInterlocutor: MockFactory {
    public static func makeMock() -> MockChatInterlocutor {
        return MockChatInterlocutor(objectId: String.makeRandom(),
                                    name: String.makeRandom(),
                                    avatar: MockFile?.makeMock(),
                                    isBanned: Bool.makeRandom(),
                                    isMuted: Bool.makeRandom(),
                                    hasMutedYou: Bool.makeRandom(),
                                    status: UserStatus.makeMock())
    }
}
