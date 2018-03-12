//
//  LGChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum ChatMessageType: String, Decodable, Equatable {
    case text = "text"
    case offer = "offer"
    case sticker = "sticker"
    case quickAnswer = "quick_answer"
    case expressChat = "express_chat"
    case favoritedListing  = "favorited_product"
    case phone = "phone"
    case chatNorris = "chat_norris"
    case interlocutorIsTyping
}

public enum ChatMessageWarning: String, Decodable {
    case spam = "spam"
}

public enum ChatMessageStatus {
    case sent
    case received
    case read
    case unknown
}

public protocol ChatMessage: BaseModel {
    var talkerId: String { get }
    var text: String { get }
    var sentAt: Date? { get }
    var receivedAt: Date? { get }
    var readAt: Date? { get }
    var type: ChatMessageType { get }
    var warnings: [ChatMessageWarning] { get }
    
    func markReceived() -> ChatMessage
}

extension ChatMessage {
    public var messageStatus: ChatMessageStatus {
        if let _ = readAt { return .read }
        if let _ = receivedAt { return .received }
        if let _ = sentAt { return .sent }
        return .unknown
    }
}

struct LGChatMessage: ChatMessage, Decodable {
    let objectId: String?
    let talkerId: String
    let text: String
    var sentAt: Date?
    var receivedAt: Date?
    var readAt: Date?
    let type: ChatMessageType
    var warnings: [ChatMessageWarning]
    
    init(objectId: String?,
         talkerId: String,
         text: String,
         sentAt: Date?,
         receivedAt: Date?,
         readAt: Date?,
         type: ChatMessageType,
         warnings: [ChatMessageWarning]) {
        
        self.objectId = objectId
        self.talkerId = talkerId
        self.text = text
        self.sentAt = sentAt
        self.receivedAt = receivedAt
        self.readAt = readAt
        self.type = type
        self.warnings = warnings
    }
    
    func markReceived() -> ChatMessage {
        return LGChatMessage(objectId: objectId,
                             talkerId: talkerId,
                             text: text, sentAt: sentAt,
                             receivedAt: receivedAt ?? Date(),
                             readAt: readAt,
                             type: type,
                             warnings: warnings)
    }
    
    // MARK: Decodable
    
    /*
     {
     "message_id": [uuid],
     "talker_id": [uuid|objectId],
     "warnings": [array[string]],
     "text": [string],
     "sent_at": [unix_timestamp],
     "received_at": [unix_timestamp|null],
     "read_at": [unix_timestamp|null],
     "type": [ChatMessageWarning]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        talkerId = try keyedContainer.decode(String.self, forKey: .talkerId)
        text = try keyedContainer.decode(String.self, forKey: .text)
        let sentAtValue = try keyedContainer.decode(Double.self, forKey: .sentAt)
        sentAt = Date.makeChatDate(millisecondsIntervalSince1970: sentAtValue)
        let receivedAtValue = try keyedContainer.decodeIfPresent(Double.self, forKey: .receivedAt)
        receivedAt = Date.makeChatDate(millisecondsIntervalSince1970: receivedAtValue)
        let readAtValue = try keyedContainer.decodeIfPresent(Double.self, forKey: .readAt)
        readAt = Date.makeChatDate(millisecondsIntervalSince1970: readAtValue)
        // ChatMessageType defaults to .text as fallback for future message types
        let stringChatMessageType = try keyedContainer.decode(String.self, forKey: .type)
        type = ChatMessageType(rawValue: stringChatMessageType) ?? .text
        warnings = (try keyedContainer.decode(FailableDecodableArray<ChatMessageWarning>.self, forKey: .warnings)).validElements
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "message_id"
        case talkerId = "talker_id"
        case text
        case sentAt = "sent_at"
        case receivedAt = "received_at"
        case readAt = "read_at"
        case type
        case warnings
    }
}
