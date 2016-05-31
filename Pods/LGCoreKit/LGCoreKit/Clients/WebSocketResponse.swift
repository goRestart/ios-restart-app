//
//  WebSocketResponse.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 22/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum WebSocketResponseType: String {
    
    case ACK                            = "ack"
    
    case Error                          = "error"
    
    case MessageList                    = "message_list"
    case ConversationCreated            = "conversation_created"
    case ConversationList               = "conversation_list"
    case ConversationDetails            = "conversation_details"
    
    case InterlocutorTypingStarted      = "interlocutor_typing_started"
    case InterlocutorTypingStopped      = "interlocutor_typing_stopped"
    case InterlocutorMessageSent        = "interlocutor_message_sent"
    case InterlocutorReceptionConfirmed = "interlocutor_reception_confirmed"
    case InterlocutorReadConfirmed      = "interlocutor_read_confirmed"
    
    enum ResponseSuperType {
        case ACK
        case Error
        case Event
        case Query
    }
    
    var superType: ResponseSuperType {
        switch self {
        case .ACK:
            return .ACK
        case .Error:
            return .Error
        case .MessageList, .ConversationCreated, .ConversationList, .ConversationDetails:
            return .Query
        case .InterlocutorTypingStarted, .InterlocutorTypingStopped, .InterlocutorMessageSent,
        .InterlocutorReceptionConfirmed, .InterlocutorReadConfirmed:
            return .Event
        }
    }
}


protocol WebSocketResponse {
    var id: String { get }
    var type: WebSocketResponseType { get }
}

struct WebSocketResponseACK: WebSocketResponse {
    var id: String
    let type: WebSocketResponseType = .ACK
    var ackedType: WebSocketRequestType
    var ackedId: String
    
    init?(dict: [String: AnyObject]) {
        guard let typeString = dict["acked_type"] as? String else { return nil }
        guard let type = WebSocketRequestType(rawValue: typeString) else { return nil }
        guard let ackedId = dict["acked_id"] as? String else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        self.id = id
        self.ackedType = type
        self.ackedId = ackedId
    }
}

struct WebSocketResponseQuery: WebSocketResponse {
    var id: String
    var type: WebSocketResponseType
    var responseToId: String
    var data: [String: AnyObject]
    
    init?(dict: [String: AnyObject]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let responseToId = dict["response_to_id"] as? String else { return nil }
        guard let data = dict["data"] as? [String: AnyObject] else { return nil }
        self.id = id
        self.type = type
        self.responseToId = responseToId
        self.data = data
    }
}

struct WebSocketResponseEvent: WebSocketResponse {
    var id: String
    var type: WebSocketResponseType
    var data: [String: AnyObject]
    
    init?(dict: [String: AnyObject]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let data = dict["data"] as? [String: AnyObject] else { return nil }
        guard type.superType == .Event else { return nil }
        self.id = id
        self.type = type
        self.data = data
    }
}

struct WebSocketResponseError: WebSocketResponse {
    var id: String
    var type: WebSocketResponseType = .Error
    var erroredId: String
    var data: [String: AnyObject]
    
    init?(dict: [String: AnyObject]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let erroredId = dict["errored_id"] as? String else { return nil }
        guard let data = dict["data"] as? [String: AnyObject] else { return nil }
        self.id = id
        self.type = type
        self.erroredId = erroredId
        self.data = data
    }
}
