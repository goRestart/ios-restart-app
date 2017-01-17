//
//  ChatEvent.swift
//  Pods
//
//  Created by Isaac Roldan on 31/3/16.
//
//

import Argo
import Curry

public enum ChatEventType {
    case interlocutorTypingStarted
    case interlocutorTypingStopped
    case interlocutorMessageSent(messageId: String, sentAt: Date, text: String, type: ChatMessageType)
    case interlocutorReceptionConfirmed(messagesIds: [String])
    case interlocutorReadConfirmed(messagesIds: [String])
    case authenticationTokenExpired
}

public protocol ChatEvent: BaseModel {
    var type: ChatEventType { get }
    var conversationId: String? { get }
}
