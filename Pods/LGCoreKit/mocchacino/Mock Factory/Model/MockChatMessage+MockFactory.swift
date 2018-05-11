extension MockChatMessage: MockFactory {
    public static func makeMock() -> MockChatMessage {
        return MockChatMessage(objectId: String.makeRandom(),
                               talkerId: String.makeRandom(),
                               sentAt: Date?.makeRandom(),
                               receivedAt: Date?.makeRandom(),
                               readAt: Date?.makeRandom(),
                               warnings: ChatMessageWarning.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                               content: MockChatMessageContent.makeMock(),
                               assistantMeeting: nil)
    }
}
