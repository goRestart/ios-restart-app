extension MockChatMessage: MockFactory {
    public static func makeMock() -> MockChatMessage {
        return MockChatMessage(objectId: String.makeRandom(),
                               talkerId: String.makeRandom(),
                               text: String.makeRandom(),
                               sentAt: Date?.makeRandom(),
                               receivedAt: Date?.makeRandom(),
                               readAt: Date?.makeRandom(),
                               type: ChatMessageType.makeMock(),
                               warnings: ChatMessageWarning.makeMocks(count: Int.makeRandom(min: 0, max: 10)))
    }
}
