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
        let result = curry(LGChatEvent.init)
            <^> j <|? "id"
            <*> j <|? ["data", "conversation_id"]
            <*> ChatEventType.decode(j)
        
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
            result = curry(ChatEventType.interlocutorMessageSent)
                <^> j <| ["data", "message_id"]
                <*> j <| ["data", "sent_at"]
                <*> j <| ["data", "text"]
                <*> LGArgo.parseChatMessageType(j, key: ["data", "message_type"])

        case "interlocutor_reception_confirmed":
            /**
             ...
             "data" : {
             "conversation_id": [uuid]
             "message_ids": [ [uuid], … ]
             }
             */
            result = curry(ChatEventType.interlocutorReceptionConfirmed)
                <^> j <|| ["data", "message_ids"]

        case "interlocutor_read_confirmed":
            /**
             ...
             "data" : {
             "conversation_id": [uuid]
             "message_ids": [ [uuid], … ]
             }
             */
            result = curry(ChatEventType.interlocutorReadConfirmed)
                <^> j <|| ["data", "message_ids"]

        case "authentication_token_expired":
            result = Decoded<ChatEventType>.success(.authenticationTokenExpired)
            
            
        default:
            result = Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.error, type: .parsing, message: "ChatEventType parse error: \(error)")
        }
        return result
    }
}
