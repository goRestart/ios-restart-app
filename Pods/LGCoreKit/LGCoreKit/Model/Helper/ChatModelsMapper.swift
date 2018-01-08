//
//  ChatModelsMapper.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 29/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation

class ChatModelsMapper {
    static func messagesFromDict(_ dict: [AnyHashable : Any]) -> [ChatMessage] {
        guard let array = dict["messages"] as? [[AnyHashable : Any]] else { return [] }
        return array.map(messageFromDict).flatMap{$0}
    }
    
    static func messageFromDict(_ dict: [AnyHashable : Any]) -> ChatMessage? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return nil }
        do {
            let chatMessage = try LGChatMessage.decode(jsonData: data)
            return chatMessage
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse ChatMessage \(dict)")
        }
        return nil
    }
    
    static func conversationsFromDict(_ dict: [AnyHashable : Any]) -> [ChatConversation] {
        guard let array = dict["conversations"] as? [[AnyHashable : Any]] else { return [] }
        return array.map(conversationFromDict).flatMap{$0}
    }
    
    static func conversationFromDict(_ dict: [AnyHashable : Any]) -> ChatConversation? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return nil }
        do {
            let conversation = try LGChatConversation.decode(jsonData: data)
            return conversation
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse LGChatConversation \(dict)")
        }
        return nil
    }
    
    static func eventFromDict(_ dict: [AnyHashable : Any], type: WebSocketResponseType) -> ChatEvent? {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return nil }
        do {
            let chatEvent = try LGChatEvent.decode(jsonData: data)
            return chatEvent
        } catch {
            logMessage(.debug, type: .parsing, message: "could not parse LGChatEvent \(dict)")
        }
        return nil
    }
}
