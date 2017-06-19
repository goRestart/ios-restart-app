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
    static func messagesFromDict(_ dict: [AnyHashable : Any]) -> [ChatMessage] {
        guard let array = dict["messages"] as? [[AnyHashable : Any]] else { return [] }
        return array.map(messageFromDict).flatMap{$0}
    }
    
    static func messageFromDict(_ dict: [AnyHashable : Any]) -> ChatMessage? {
        guard let message: LGChatMessage = decode(dict) else { return nil }
        return message
    }
    
    static func conversationsFromDict(_ dict: [AnyHashable : Any]) -> [ChatConversation] {
        guard let array = dict["conversations"] as? [[AnyHashable : Any]] else { return [] }
        return array.map(conversationFromDict).flatMap{$0}
    }
    
    static func conversationFromDict(_ dict: [AnyHashable : Any]) -> ChatConversation? {
        guard let conversation: LGChatConversation = decode(dict) else { return nil }
        return conversation
    }
    
    static func eventFromDict(_ dict: [AnyHashable : Any], type: WebSocketResponseType) -> ChatEvent? {
        guard let event: LGChatEvent = decode(dict) else { return nil }
        return event
    }
}
