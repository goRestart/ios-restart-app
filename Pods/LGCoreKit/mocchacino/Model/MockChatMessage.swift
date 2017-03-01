public struct MockChatMessage: ChatMessage {
    public var objectId: String?
    public var talkerId: String
    public var text: String
    public var sentAt: Date?
    public var receivedAt: Date?
    public var readAt: Date?
    public var type: ChatMessageType
    public var warnings: [ChatMessageWarning]

    public func markReceived() -> ChatMessage {
        return MockChatMessage(objectId: objectId,
                               talkerId: talkerId,
                               text: text,
                               sentAt: sentAt,
                               receivedAt: Date(),
                               readAt: readAt,
                               type: type,
                               warnings: warnings)
    }
}
