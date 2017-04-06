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
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["message_id"] = objectId
        result["talker_id"] = talkerId
        result["text"] = text
        result["sent_at"] = Int64((sentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result["type"] = type.rawValue
        result["warnings"] = warnings.flatMap { $0.rawValue }
        result["received_at"] = Int64((receivedAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result["read_at"] = Int64((readAt ?? Date()).timeIntervalSince1970 * 1000.0)
        return result
    }
}
