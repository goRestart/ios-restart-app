extension MockChatEvent: MockFactory {
    public static func makeMock() -> MockChatEvent {
        return makeMock(type: ChatEventType.makeMock())
    }
    
    public static func makeMock(type: ChatEventType) -> MockChatEvent {
        return MockChatEvent(objectId: String.makeRandom(),
                             conversationId: String?.makeRandom(),
                             type: type)
    }
    
    public static func makeMessageSentMock() -> MockChatEvent {
        return MockChatEvent(objectId: String.makeRandom(),
                             conversationId: String.makeRandom(),
                             type: .interlocutorMessageSent(messageId: String.makeRandom(),
                                                            sentAt: Date.makeChatDate(millisecondsIntervalSince1970: Date().millisecondsSince1970())!,
                                                            content: MockChatMessageContent(type: .text, text: String.makeRandom())))
    }
}
