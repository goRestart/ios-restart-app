//
//  ChatModelsMapper.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 29/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo

class ChatModelsMapper {
    static func messagesFromDict(_ dict: [String : Any]) -> [ChatMessage] {
        guard let array = dict["messages"] as? [[String : Any]] else { return [] }
        return array.map(messageFromDict).flatMap{$0}
    }
    
    static func messageFromDict(_ dict: [String : Any]) -> ChatMessage? {
        guard let message: LGChatMessage = decode(dict) else { return nil }
        return message
    }
    
    static func conversationsFromDict(_ dict: [String : Any]) -> [ChatConversation] {
        guard let array = dict["conversations"] as? [[String : Any]] else { return [] }
        return array.map(conversationFromDict).flatMap{$0}
    }
    
    static func conversationFromDict(_ dict: [String : Any]) -> ChatConversation? {
        guard let conversation: LGChatConversation = decode(dict) else { return nil }
        return conversation
    }
    
    static func eventFromDict(_ dict: [String : Any], type: WebSocketResponseType) -> ChatEvent? {
        guard let event: LGChatEvent = decode(dict) else { return nil }
        return event
    }
}
