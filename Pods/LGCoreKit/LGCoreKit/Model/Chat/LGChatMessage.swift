//
//  LGChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

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
    var sentAt: Date? { get }
    var receivedAt: Date? { get }
    var readAt: Date? { get }
    var warnings: [ChatMessageWarning] { get }
    var content: ChatMessageContent { get }
    var assistantMeeting: AssistantMeeting? { get }
    
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
    let sentAt: Date?
    let receivedAt: Date?
    let readAt: Date?
    let warnings: [ChatMessageWarning]
    let content: ChatMessageContent
    let assistantMeeting: AssistantMeeting?
    
    init(objectId: String?,
         talkerId: String,
         sentAt: Date?,
         receivedAt: Date?,
         readAt: Date?,
         warnings: [ChatMessageWarning],
         content: ChatMessageContent) {
        
        self.objectId = objectId
        self.talkerId = talkerId
        self.sentAt = sentAt
        self.receivedAt = receivedAt
        self.readAt = readAt
        self.warnings = warnings
        self.content = content
        self.assistantMeeting = content.type == .meeting ? LGAssistantMeeting.makeMeeting(from: content.text) : nil
    }
    
    static func make(messageId: String?, talkerId: String, text: String?, type: ChatMessageType) -> ChatMessage {
        // if the message type is QuickAnswer with a key, we need to send it as the message_id (blame our backend/tracking requirements)
        return LGChatMessage(objectId: type.quickAnswerId ?? messageId ?? LGUUID().UUIDString,
                             talkerId: talkerId,
                             sentAt: nil,
                             receivedAt: nil,
                             readAt: nil,
                             warnings: [],
                             content: LGChatMessageContent(type: type, defaultText: nil, text: text))
    }
    
    func markReceived() -> ChatMessage {
        return LGChatMessage(objectId: objectId,
                             talkerId: talkerId,
                             sentAt: sentAt,
                             receivedAt: receivedAt ?? Date(),
                             readAt: readAt,
                             warnings: warnings,
                             content: content)
    }
    
    // MARK: Decodable
    
    /*
     {
     "message_id": [uuid],
     "talker_id": [uuid|objectId],
     "warnings": [array[string]],
     "sent_at": [unix_timestamp],
     "received_at": [unix_timestamp|null],
     "read_at": [unix_timestamp|null],
     "content": {
        "text": "Hi! I'd like to buy it",
        "type": "unknown_type",
        "default": "You've received a message not supported for your app version.
                    \nPlease update your app to use the newest features!"
     }
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        talkerId = try keyedContainer.decode(String.self, forKey: .talkerId)
        let sentAtValue = try keyedContainer.decode(TimeInterval.self, forKey: .sentAt)
        sentAt = Date.makeChatDate(millisecondsIntervalSince1970: sentAtValue)
        let receivedAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .receivedAt)
        receivedAt = Date.makeChatDate(millisecondsIntervalSince1970: receivedAtValue)
        let readAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .readAt)
        readAt = Date.makeChatDate(millisecondsIntervalSince1970: readAtValue)
        warnings = (try keyedContainer.decode(FailableDecodableArray<ChatMessageWarning>.self, forKey: .warnings)).validElements
        content = try keyedContainer.decode(LGChatMessageContent.self, forKey: .content)
        assistantMeeting = content.type == .meeting ? LGAssistantMeeting.makeMeeting(from: content.text) : nil
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "message_id"
        case talkerId = "talker_id"
        case sentAt = "sent_at"
        case receivedAt = "received_at"
        case readAt = "read_at"
        case warnings
        case content
    }
}
