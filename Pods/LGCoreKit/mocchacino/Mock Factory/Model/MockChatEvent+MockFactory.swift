extension MockChatEvent: MockFactory {
    public static func makeMock() -> MockChatEvent {
        return makeMock(type: ChatEventType.makeMock())
    }
    
    public static func makeMock(type: ChatEventType) -> MockChatEvent {
        return MockChatEvent(objectId: String.makeRandom(),
                             type: type,
                             conversationId: String?.makeRandom())
    }
}
