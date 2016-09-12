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
    case InterlocutorTypingStarted
    case InterlocutorTypingStopped
    case InterlocutorMessageSent(messageId: String, sentAt: NSDate, text: String, type: ChatMessageType)
    case InterlocutorReceptionConfirmed(messagesIds: [String])
    case InterlocutorReadConfirmed(messagesIds: [String])
    case AuthenticationTokenExpired
}

public protocol ChatEvent: BaseModel {
    var type: ChatEventType { get }
    var conversationId: String? { get }
}
