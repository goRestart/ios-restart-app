//
//  WebSocketResponse.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 22/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum WebSocketErrorType: Int {
    case NotAuthenticated = 3000
    case TalkerPermissionsError = 3001 // `talker` does not have permissions for `conversation`
    case InternalServerError = 3008
    case ConversationWithYourself = 3009 // You can't fetch conversation id with yourself
    case SellerDoesNotExists = 3010
    case SellerDoesNotOwnProduct = 3011
    case RetrievingProductInfoError = 3012
    
    case UserNotFound = 6404
    case Unauthorized = 6401
    case Forbidden = 6403
    case IsScammer = 6418
    case AuthUnknownError = 6001
    case TokenExpired = 6003
    case InvalidToken = 6004
    case UserNotLoggedIn = 6005
    
    case UnknownError = 0
    
    init(code: Int) {
        let error = WebSocketErrorType(rawValue: code)
        self = error ?? ("\(code)".hasPrefix("6") ? .AuthUnknownError : .UnknownError)
    }
}


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
    case AuthenticationTokenExpired     = "authentication_token_expired"
    case Pong                           = "pong"
    
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
        case .MessageList, .ConversationCreated, .ConversationList, .ConversationDetails, .Pong:
            return .Query
        case .InterlocutorTypingStarted, .InterlocutorTypingStopped, .InterlocutorMessageSent,
        .InterlocutorReceptionConfirmed, .InterlocutorReadConfirmed, .AuthenticationTokenExpired:
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
    var errorType: WebSocketErrorType
    var erroredId: String
    var data: [String: AnyObject]
    
    init?(dict: [String: AnyObject]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let erroredId = dict["errored_id"] as? String else { return nil }
        guard let data = dict["data"] as? [String: AnyObject] else { return nil }
        guard let errorCode = data["code"] as? Int else { return nil }
        self.id = id
        self.type = type
        self.errorType = WebSocketErrorType(code: errorCode)
        self.erroredId = erroredId
        self.data = data
    }
}
