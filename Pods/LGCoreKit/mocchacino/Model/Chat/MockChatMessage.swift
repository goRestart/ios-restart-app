public struct MockChatMessage: ChatMessage {
    public var objectId: String?
    public var talkerId: String
    public var sentAt: Date?
    public var receivedAt: Date?
    public var readAt: Date?
    public var warnings: [ChatMessageWarning]
    public var content: ChatMessageContent
    public var assistantMeeting: AssistantMeeting?

    public func markReceived() -> ChatMessage {
        return MockChatMessage(objectId: objectId,
                               talkerId: talkerId,
                               sentAt: sentAt,
                               receivedAt: Date(),
                               readAt: readAt,
                               warnings: warnings,
                               content: content,
                               assistantMeeting: assistantMeeting)
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatMessage.CodingKeys.objectId.rawValue] = objectId
        result[LGChatMessage.CodingKeys.talkerId.rawValue] = talkerId
        result[LGChatMessage.CodingKeys.sentAt.rawValue] = Int64((sentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result[LGChatMessage.CodingKeys.warnings.rawValue] = warnings.map { $0.rawValue }
        result[LGChatMessage.CodingKeys.receivedAt.rawValue] = Int64((receivedAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result[LGChatMessage.CodingKeys.readAt.rawValue] = Int64((readAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result[LGChatMessage.CodingKeys.content.rawValue] = MockChatMessageContent.makeMock().makeDictionary()
        return result
    }
}
