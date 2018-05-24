public struct MockChatEvent: ChatEvent {
    public var objectId: String?
    public var conversationId: String?
    public var type: ChatEventType
    
    public var talkerId: String

    public init(objectId: String?,
                conversationId: String?,
                type: ChatEventType,
                talkerId: String = String.makeRandom()) {
        self.objectId = objectId
        self.conversationId = conversationId
        self.type = type
        self.talkerId = talkerId
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["id"] = objectId
        let typeRawValue = LGChatEvent.CodingKeys.type.rawValue
        let dataRawValue = "data"
        switch type {
        case .interlocutorTypingStarted:
            result[typeRawValue] = ChatEventTypeDecodable.interlocutorTypingStarted.rawValue
            result[dataRawValue] = makeInterloctuorStoppedTypingData(conversationId: conversationId)
        case .interlocutorTypingStopped:
            result[typeRawValue] = ChatEventTypeDecodable.interlocutorTypingStopped.rawValue
            result[dataRawValue] = makeInterloctuorStoppedTypingData(conversationId: conversationId)
        case .interlocutorMessageSent(let messageId, let sentAt, let content):
            result[typeRawValue] = ChatEventTypeDecodable.interlocutorMessageSent.rawValue
            result[dataRawValue] = makeMessageSentData(conversationId: conversationId,
                                                       messageId: messageId,
                                                       sentAt: sentAt,
                                                       warnings: [],
                                                       content: content)
        case .interlocutorReceptionConfirmed(let messagesIds):
            result[typeRawValue] = ChatEventTypeDecodable.interlocutorReceptionConfirmed.rawValue
            result[dataRawValue] = makeReceptionConfirmedData(conversationId: conversationId,
                                                              messageIds: messagesIds)
        case .interlocutorReadConfirmed(let messagesIds):
            result[typeRawValue] = ChatEventTypeDecodable.interlocutorReadConfirmed.rawValue
            result[dataRawValue] = makeReadConfirmedData(conversationId: conversationId,
                                                         messageIds: messagesIds)
        case .authenticationTokenExpired:
            result[typeRawValue] = ChatEventTypeDecodable.authenticationTokenExpired.rawValue
            result[dataRawValue] = makeAuthenticationTokenExpiredData(talkerId: talkerId)
        case .talkerUnauthenticated:
            result[typeRawValue] = ChatEventTypeDecodable.talkerUnauthenticated.rawValue
            result[dataRawValue] = makeTalkerAuthenticatedData(talkerId: talkerId)
        }
        return result
    }
    
    private func makeInterlocutorStartedTypingData(conversationId: String?) -> [String: Any] {
        var data = [String: Any]()
        data[ChatEventDataDecodable.CodingKeys.conversationId.rawValue] = conversationId
        return data
    }
    
    private func makeInterloctuorStoppedTypingData(conversationId: String?) -> [String: Any] {
        var data = [String: Any]()
        data[ChatEventDataDecodable.CodingKeys.conversationId.rawValue] = conversationId
        return data
    }
    
    private func makeMessageSentData(conversationId: String?,
                                     messageId: String,
                                     sentAt: Date,
                                     warnings: [ChatMessageWarning],
                                     content: ChatMessageContent) -> [String: Any] {
        var data = [String: Any]()
        data[ChatEventDataDecodable.CodingKeys.conversationId.rawValue] = conversationId
        data[ChatEventDataDecodable.CodingKeys.messageId.rawValue] = messageId
        data[ChatEventDataDecodable.CodingKeys.sentAt.rawValue] = sentAt.millisecondsSince1970()
        data[ChatEventDataDecodable.CodingKeys.warnings.rawValue] = warnings.map { $0.rawValue }
        data[ChatEventDataDecodable.CodingKeys.content.rawValue] = MockChatMessageContent(from: content).makeDictionary()
        return data
    }
    
    private func makeReceptionConfirmedData(conversationId: String?,
                                            messageIds: [String]) -> [String: Any] {
        var data = [String: Any]()
        data[ChatEventDataDecodable.CodingKeys.conversationId.rawValue] = conversationId
        data[ChatEventDataDecodable.CodingKeys.messageIds.rawValue] = messageIds
        return data
    }
    
    private func makeReadConfirmedData(conversationId: String?,
                                       messageIds: [String]) -> [String: Any] {
        var data = [String: Any]()
        data[ChatEventDataDecodable.CodingKeys.conversationId.rawValue] = conversationId
        data[ChatEventDataDecodable.CodingKeys.messageIds.rawValue] = messageIds
        return data
    }
    
    private func makeAuthenticationTokenExpiredData(talkerId: String) -> [String: Any] {
        return [ChatEventDataDecodable.CodingKeys.talkerId.rawValue: talkerId]
    }
    
    private func makeTalkerAuthenticatedData(talkerId: String) -> [String: Any] {
        return [ChatEventDataDecodable.CodingKeys.talkerId.rawValue: talkerId]
    }
}
