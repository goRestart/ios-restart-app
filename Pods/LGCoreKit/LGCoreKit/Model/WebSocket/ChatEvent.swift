//
//  ChatEvent.swift
//  Pods
//
//  Created by Isaac Roldan on 31/3/16.
//
//

import Argo
import Curry

public enum ChatEventType: String {
    case InterlocutorTypingStarted      = "interlocutor_typing_started"
    case InterlocutorTypingStopped      = "interlocutor_typing_stopped"
    case InterlocutorMessageSent        = "interlocutor_message_sent"
    case InterlocutorReceptionConfirmed = "interlocutor_reception_confirmed"
    case InterlocutorReadConfirmed      = "interlocutor_read_confirmed"
    case Unknown                        = "unknown"
}

public protocol ChatEvent: BaseModel {
    var type: ChatEventType { get }
    var conversationId: String { get }
}
