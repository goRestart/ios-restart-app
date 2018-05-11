//
//  LGChatInactiveConversation.swift
//  LGCoreKit
//
//  Created by Nestor on 11/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public protocol ChatInactiveConversation: BaseModel {
    var lastMessageSentAt: Date? { get }
    var listing: ChatListing? { get }
    var interlocutor: ChatInterlocutor? { get }
    var messages: [ChatInactiveMessage] { get }
}

struct LGChatInactiveConversation: ChatInactiveConversation, Decodable {
    let objectId: String?
    let lastMessageSentAt: Date?
    let listing: ChatListing?
    let interlocutor: ChatInterlocutor?
    let messages: [ChatInactiveMessage]
    
    // MARK: Decodable
    
    /*
     {
     "conversation_id": "44572c38-df4a-4d4d-85e4-fe05a9b36c87",
     "last_message_sent_at": 1514585103615,
     "product": {
         "id": "68584fa9-b004-4050-9702-6164ec9370e5",
         "name": "tablero a cuadros blanco y negro =",
         "status": 1,
         "image": "http://cdn.stg.letgo.com/images/8b/32/6e/ef/8b326eef0fc6223ea61ea809977af476.jpeg",
         "price": {
         "amount": 12,
         "currency": "EUR",
         "flag": 2
     }
     },
     "interlocutor": {
         "id": "dbc364b6-4e26-49dc-a015-dc7820262715",
         "name": "Albert Beade",
         "is_banned": false,
         "status": "active",
         "is_muted": false,
         "has_muted_you": false
     },
     "messages": [{
         "id": "1e68fa71-159a-4f75-97ae-86b449d2b0cf",
         "talker_id": "194853ed-f553-47dc-9ccc-e57a41df110b",
         "text": "Hi! I'd like to buy it",
         "warnings": [],
         "type": "quick_answer",
         "sent_at": 1514585103615,
         "content": {
         "text": "Hi! I'd like to buy it",
         "type": "quick_answer"
     }, {
         "id": "5315c7eb-d4d3-4794-96c9-2558c32913a8",
         "talker_id": "194853ed-f553-47dc-9ccc-e57a41df110b",
         "text": "Hi! I'd like to buy it",
         "warnings": [],
         "type": "quick_answer",
         "sent_at": 1514579418571,
         "content": {
         "text": "Hi! I'd like to buy it",
         "type": "quick_answer"
     }
     }\\
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        let lastMessageSentAtValue = try keyedContainer.decodeIfPresent(TimeInterval.self, forKey: .lastMessageSentAt)
        lastMessageSentAt = Date.makeChatDate(millisecondsIntervalSince1970: lastMessageSentAtValue)
        listing = try keyedContainer.decodeIfPresent(LGChatListing.self, forKey: .listing)
        interlocutor = try keyedContainer.decodeIfPresent(LGChatInterlocutor.self, forKey: .interlocutor)
        messages = (try keyedContainer.decode(FailableDecodableArray<LGChatInactiveMessage>.self, forKey: .messages)).validElements
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "conversation_id"
        case lastMessageSentAt = "last_message_sent_at"
        case listing = "product"
        case interlocutor
        case messages
    }
}

