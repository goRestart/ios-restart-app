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
    static func messagesFromDict(dict: [String: AnyObject]) -> [ChatMessage] {
        guard let array = dict["messages"] as? [[String: AnyObject]] else { return [] }
        return array.map(messageFromDict).flatMap{$0}
    }
    
    static func messageFromDict(dict: [String: AnyObject]) -> ChatMessage? {
        guard let message: LGChatMessage = decode(dict) else { return nil }
        return message
    }
    
    static func conversationsFromDict(dict: [String: AnyObject]) -> [ChatConversation] {
        guard let array = dict["conversations"] as? [[String: AnyObject]] else { return [] }
        return array.map(conversationFromDict).flatMap{$0}
    }
    
    static func conversationFromDict(dict: [String: AnyObject]) -> ChatConversation? {
        guard let conversation: LGChatConversation = decode(dict) else { return nil }
        return conversation
    }
    
    static func eventFromDict(dict: [String: AnyObject], type: WebSocketResponseType) -> ChatEvent? {
       
        switch type {
        case .InterlocutorMessageSent:
            guard let event: LGChatEventInterlocutorMessageSent = decode(dict) else { return nil }
            return event
        case .InterlocutorReadConfirmed:
            guard let event: LGChatEventInterlocutorReadConfirmed = decode(dict) else { return nil }
            return event
        case .InterlocutorReceptionConfirmed:
            guard let event: LGChatEventInterlocutorReceptionConfirmed = decode(dict) else { return nil }
            return event
        case .InterlocutorTypingStarted:
            guard let event: LGChatEventInterlocutorTypingStarted = decode(dict) else { return nil }
            return event
        case .InterlocutorTypingStopped:
            guard let event: LGChatEventInterlocutorTypingStopped = decode(dict) else { return nil }
            return event
    
        case .ACK, .ConversationCreated, .ConversationDetails, .ConversationList, .Error, .MessageList:
            return nil
        }
    }
}
