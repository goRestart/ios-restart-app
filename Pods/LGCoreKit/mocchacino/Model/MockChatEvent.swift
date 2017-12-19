public struct MockChatEvent: ChatEvent {
    public var objectId: String?
    public var type: ChatEventType
    public var conversationId: String?
}
