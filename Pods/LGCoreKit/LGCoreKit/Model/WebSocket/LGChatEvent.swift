//
//  LGChatEvent.swift
//  Pods
//
//  Created by Isaac Roldan on 29/4/16.
//
//

import Argo
import Curry
import Runes

struct LGChatEvent: ChatEvent {
    var objectId: String?
    var conversationId: String?
    var type: ChatEventType
}

extension LGChatEvent: Decodable {
    
    /**
     "id": [uuid],
     "type": "interlocutor_reception_confirmed"/[...],  // Chat Type identifier
     "data" : {
     // Specific data of the chat event
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGChatEvent> {
        let result1 = curry(LGChatEvent.init)
        let result2 = result1 <^> j <|? "id"
        let result3 = result2 <*> j <|? ["data", "conversation_id"]
        let result  = result3 <*> ChatEventType.decode(j)
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGChatEvent parse error: \(error)")
        }
        return result
    }
}

extension ChatEventType: Decodable {
    public static func decode(_ j: JSON) -> Decoded<ChatEventType> {
        guard let type: String = j.decode("type") else { return Decoded<ChatEventType>.fromOptional(nil) }
        
        let result: Decoded<ChatEventType>
        switch type {
            
            
        case "interlocutor_typing_started":
            /**
             ...
             "data": {
             "conversation_id": [uuid],
             }
             */
            result = Decoded<ChatEventType>.success(.interlocutorTypingStarted)

        case "interlocutor_typing_stopped":
            /**
             ...
             "data": {
             "conversation_id": [uuid],
             }
             */
            result = Decoded<ChatEventType>.success(.interlocutorTypingStopped)
            
        case "interlocutor_message_sent":
            /**
             ...
             "data": {
             "message_id": [uuid],
             "conversation_id": [uuid],
             "sent_at": [unix_timestamp],
             "text": [string]
             }
             */
            let result1 = curry(ChatEventType.interlocutorMessageSent)
            let result2 = result1 <^> j <| ["data", "message_id"]
            let result3 = result2 <*> j <| ["data", "sent_at"]
            let result4 = result3 <*> j <| ["data", "text"]
            result      = result4 <*> LGArgo.parseChatMessageType(j, key: ["data", "message_type"])

        case "interlocutor_reception_confirmed":
            /**
             ...
             "data" : {
             "conversation_id": [uuid]
             "message_ids": [ [uuid], … ]
             }
             */
            let result1 = curry(ChatEventType.interlocutorReceptionConfirmed)
            result      = result1 <^> j <|| ["data", "message_ids"]

        case "interlocutor_read_confirmed":
            /**
             ...
             "data" : {
             "conversation_id": [uuid]
             "message_ids": [ [uuid], … ]
             }
             */
            let result1 = curry(ChatEventType.interlocutorReadConfirmed)
            result      = result1 <^> j <|| ["data", "message_ids"]

        case "authentication_token_expired":
            result = Decoded<ChatEventType>.success(.authenticationTokenExpired)

        case "talker_unauthenticated":
            /*
             {
             "id": [uuid],
             "type": "talker_unauthenticated",
             "data": {
             "talker_id": [uuid]
             }
             }
             */
            result = Decoded<ChatEventType>.success(.talkerUnauthenticated)

        default:
            result = Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.error, type: .parsing, message: "ChatEventType parse error: \(error)")
        }
        return result
    }
}
