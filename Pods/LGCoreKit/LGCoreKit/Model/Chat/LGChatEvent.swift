//
//  LGChatEvent.swift
//  Pods
//
//  Created by Isaac Roldan on 29/4/16.
//
//

public enum ChatEventType: Equatable {
    case interlocutorTypingStarted
    case interlocutorTypingStopped
    case interlocutorMessageSent(messageId: String, sentAt: Date, content: ChatMessageContent)
    case interlocutorReceptionConfirmed(messagesIds: [String])
    case interlocutorReadConfirmed(messagesIds: [String])
    case authenticationTokenExpired
    case talkerUnauthenticated
    
    public static func ==(a: ChatEventType, b: ChatEventType) -> Bool {
        switch (a, b) {
        case (.interlocutorTypingStarted, .interlocutorTypingStarted):
            return true
        case (.interlocutorTypingStopped, .interlocutorTypingStopped):
            return true
        case (.interlocutorMessageSent(let messageIdA, let sentAtA, let contentA),
              .interlocutorMessageSent(let messageIdB, let sentAtB, let contentB)):
            guard let lgContentA = contentA as? LGChatMessageContent,
                let lgContentB = contentB as? LGChatMessageContent else { return false }
            return messageIdA == messageIdB && sentAtA == sentAtB && lgContentA == lgContentB
        case (.interlocutorReceptionConfirmed(let messageIdsA),
              .interlocutorReceptionConfirmed(let messageIdsB)):
            return messageIdsA == messageIdsB
        case (.interlocutorReadConfirmed(let messageIdsA),
              .interlocutorReadConfirmed(let messageIdsB)):
            return messageIdsA == messageIdsB
        case (.authenticationTokenExpired, .authenticationTokenExpired):
            return true
        case (.talkerUnauthenticated, .talkerUnauthenticated):
            return true
        default: return false
        }
    }
}

public protocol ChatEvent: BaseModel {
    var type: ChatEventType { get }
    var conversationId: String? { get }
}

struct LGChatEvent: ChatEvent, Decodable {
    var objectId: String?
    var conversationId: String?
    var type: ChatEventType
    
    // MARK: Decodable
    
    /*
     Interlocutor typing started
     {
     "id" : [uuid],
     "type": "interlocutor_typing_started",
     "data": {
     "conversation_id": [uuid],
     }
     }
     
     Interlocutor typing stopped
     {
     "id" : [uuid],
     "type": "interlocutor_typing_stopped",
     "data": {
     "conversation_id": [uuid],
     }
     }
     
     Interlocutor message sent (The interlocutor has sent a new message)
     {
     "id": [uuid],
     "type": "interlocutor_message_sent",
     "data": {
     "message_id": [uuid],
     "conversation_id": [uuid],
     "warnings": [array[string]]
     "sent_at": [unix_timestamp],
     "content": {
        "text": "Hi! I'd like to buy it",
        "type": "text",
        "default": "You've received a message not supported for your app version.
                    \nPlease update your app to use the newest features!"
     }
     }
     }
     
     Interlocutor reception confirmed (interlocutor has received your message successfully)
     {
     "id": [uuid],
     "type": "interlocutor_reception_confirmed",
     "data" : {
     "conversation_id": [uuid]
     "message_ids": [array[uuid]]
     }
     }
     
     Interlocutor read confirmed
     interlocutor has read your message successfully
     {
     "id": [uuid],
     "type": "interlocutor_read_confirmed",
     "data" : {
     "conversation_id": [uuid]
     "message_ids": [array[uuid]]
     }
     }
     
     Talker unauthenticated
     {
     "id": [uuid],
     "type": "talker_unauthenticated",
     "data": {
     "talker_id": [uuid]
     }
     }
     
     Authentication token expired
     {
     "id": [uuid],
     "type": "authentication_token_expired",
     "data": {
     "talker_id": [uuid|objectId]
     }
     }
     
     */ 
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        let data = try keyedContainer.decode(ChatEventDataDecodable.self, forKey: .data)
        conversationId = data.conversationId
        let eventTypeStringDecoded = try keyedContainer.decode(ChatEventTypeDecodable.self, forKey: .type)
        switch eventTypeStringDecoded {
        case .interlocutorTypingStarted:
            type = .interlocutorTypingStarted
        case .interlocutorTypingStopped:
            type = .interlocutorTypingStopped
        case .interlocutorMessageSent:
            guard let messageId = data.messageId,
                let sendAt = data.sentAt,
                let content = data.content
            else {
                throw DecodingError.valueNotFound(ChatEventDataDecodable.self,
                                                  DecodingError.Context(codingPath: [],
                                                                        debugDescription: "\(data)"))
            }
            type = .interlocutorMessageSent(messageId: messageId,
                                            sentAt: sendAt,
                                            content: content)
        case .interlocutorReceptionConfirmed:
            guard let messageIds = data.messageIds else {
                throw DecodingError.valueNotFound(ChatEventDataDecodable.self,
                                                  DecodingError.Context(codingPath: [],
                                                                        debugDescription: "\(data)"))
            }
            type = .interlocutorReceptionConfirmed(messagesIds: messageIds)
        case .interlocutorReadConfirmed:
            guard let messageIds = data.messageIds else {
                throw DecodingError.valueNotFound(ChatEventDataDecodable.self,
                                                  DecodingError.Context(codingPath: [],
                                                                        debugDescription: "\(data)"))
            }
            type = .interlocutorReadConfirmed(messagesIds: messageIds)
        case .authenticationTokenExpired:
            type = .authenticationTokenExpired
        case .talkerUnauthenticated:
            type = .talkerUnauthenticated
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case type
        case data
    }
}

enum ChatEventTypeDecodable: String, Decodable {
    case interlocutorTypingStarted = "interlocutor_typing_started"
    case interlocutorTypingStopped = "interlocutor_typing_stopped"
    case interlocutorMessageSent = "interlocutor_message_sent"
    case interlocutorReceptionConfirmed = "interlocutor_reception_confirmed"
    case interlocutorReadConfirmed = "interlocutor_read_confirmed"
    case authenticationTokenExpired = "authentication_token_expired"
    case talkerUnauthenticated = "talker_unauthenticated"
}

struct ChatEventDataDecodable: Decodable {
    let messageId: String?
    let messageIds: [String]?
    let conversationId: String?
    let warnings: [ChatMessageWarning]?
    let sentAt: Date?
    let talkerId: String?
    let content: ChatMessageContent?
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        messageId = try keyedContainer.decodeIfPresent(String.self, forKey: .messageId)
        messageIds = try keyedContainer.decodeIfPresent([String].self, forKey: .messageIds)
        conversationId = try keyedContainer.decodeIfPresent(String.self, forKey: .conversationId)
        warnings = (try keyedContainer.decodeIfPresent(FailableDecodableArray<ChatMessageWarning>.self, forKey: .warnings))?.validElements
        let sentAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .sentAt)
        sentAt = Date.makeChatDate(millisecondsIntervalSince1970: sentAtValue)
        talkerId = try keyedContainer.decodeIfPresent(String.self, forKey: .talkerId)
        content = try keyedContainer.decodeIfPresent(LGChatMessageContent.self, forKey: .content)
    }
    
    enum CodingKeys: String, CodingKey {
        case messageId = "message_id"
        case messageIds = "message_ids"
        case conversationId = "conversation_id"
        case warnings
        case sentAt = "sent_at"
        case talkerId = "talker_id"
        case content
    }
}
