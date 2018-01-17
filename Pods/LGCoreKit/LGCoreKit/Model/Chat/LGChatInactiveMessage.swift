//
//  LGChatInactiveMessage.swift
//  LGCoreKit
//
//  Created by Nestor on 11/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public protocol ChatInactiveMessage: BaseModel {
    var talkerId: String { get }
    var sentAt: Date? { get }
    var warnings: [ChatMessageWarning] { get }
    var content: ChatMessageContent { get }
}

struct LGChatInactiveMessage: ChatInactiveMessage, Decodable {
    let objectId: String?
    let talkerId: String
    let sentAt: Date?
    let warnings: [ChatMessageWarning]
    let content: ChatMessageContent

    // MARK: Decodable

    /*
     {
     "message_id": "5315c7eb-d4d3-4794-96c9-2558c32913a8",
     "talker_id": "194853ed-f553-47dc-9ccc-e57a41df110b",
     "warnings": [],
     "sent_at": 1514579418571,
     "content": {
         "text": "Hi! I'd like to buy it",
         "type": "unknown_type",
         "default": "You've received a message not supported for your app version.\nPlease update your app to use the newest features!"
     }
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        talkerId = try keyedContainer.decode(String.self, forKey: .talkerId)
        let sentAtValue = try keyedContainer.decodeIfPresent(Double.self, forKey: .sentAt)
        sentAt = Date.chatDate(millisecondsIntervalSince1970: sentAtValue)
        warnings = (try keyedContainer.decode(FailableDecodableArray<ChatMessageWarning>.self, forKey: .warnings)).validElements
        content = try keyedContainer.decode(LGChatMessageContent.self, forKey: .content)
    }

    enum CodingKeys: String, CodingKey {
        case objectId = "message_id"
        case talkerId = "talker_id"
        case sentAt = "sent_at"
        case warnings
        case content
    }
}

