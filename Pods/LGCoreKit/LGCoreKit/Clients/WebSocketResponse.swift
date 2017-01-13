//
//  WebSocketResponse.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 22/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum WebSocketErrorType: Int {
    case notAuthenticated = 3000
    case talkerPermissionsError = 3001 // `talker` does not have permissions for `conversation`
    case internalServerError = 3008
    case conversationWithYourself = 3009 // You can't fetch conversation id with yourself
    case sellerDoesNotExists = 3010
    case sellerDoesNotOwnProduct = 3011
    case retrievingProductInfoError = 3012
    
    case userNotFound = 6404
    case unauthorized = 6401
    case forbidden = 6403
    case isScammer = 6418
    case authUnknownError = 6001
    case tokenExpired = 6003
    case invalidToken = 6004
    case userNotLoggedIn = 6005
    case userNotVerified = 6013
    
    case unknownError = 0
    
    init(code: Int) {
        let error = WebSocketErrorType(rawValue: code)
        self = error ?? ("\(code)".hasPrefix("6") ? .authUnknownError : .unknownError)
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
        case ack
        case error
        case event
        case query
    }
    
    var superType: ResponseSuperType {
        switch self {
        case .ACK:
            return .ack
        case .Error:
            return .error
        case .MessageList, .ConversationCreated, .ConversationList, .ConversationDetails, .Pong:
            return .query
        case .InterlocutorTypingStarted, .InterlocutorTypingStopped, .InterlocutorMessageSent,
        .InterlocutorReceptionConfirmed, .InterlocutorReadConfirmed, .AuthenticationTokenExpired:
            return .event
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
    
    init?(dict: [String: Any]) {
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
    var data: [String: Any]
    
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let responseToId = dict["response_to_id"] as? String else { return nil }
        guard let data = dict["data"] as? [String: Any] else { return nil }
        self.id = id
        self.type = type
        self.responseToId = responseToId
        self.data = data
    }
}

struct WebSocketResponseEvent: WebSocketResponse {
    var id: String
    var type: WebSocketResponseType
    var data: [String: Any]
    
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let data = dict["data"] as? [String: Any] else { return nil }
        guard type.superType == .event else { return nil }
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
    var data: [String: Any]
    
    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String else { return nil }
        guard let typeString = dict["type"] as? String else { return nil }
        guard let type = WebSocketResponseType(rawValue: typeString) else { return nil }
        guard let erroredId = dict["errored_id"] as? String else { return nil }
        guard let dataArray = dict["data"] as? [Any] else { return nil }
        guard let data = dataArray[0] as? [String: Any] else { return nil }
        guard let errorCode = data["code"] as? Int else { return nil }
        self.id = id
        self.type = type
        self.errorType = WebSocketErrorType(code: errorCode)
        self.erroredId = erroredId
        self.data = data
    }
}
