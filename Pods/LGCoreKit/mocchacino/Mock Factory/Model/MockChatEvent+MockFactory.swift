extension MockChatEvent: MockFactory {
    public static func makeMock() -> MockChatEvent {
        return MockChatEvent(objectId: String.makeRandom(),
                             type: ChatEventType.makeMock(),
                             conversationId: String?.makeRandom())
    }
}
