//
//  WebSocketRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum WebSocketRequestType: String {
    
    // Commands
    case Authenticate           = "authenticate"
    case SendMessage            = "send_message"
    case ConfirmReception       = "confirm_reception"
    case ConfirmRead            = "confirm_read"
    case ArchiveConversations   = "archive_conversations"
    case UnarchiveConversations = "unarchive_conversations"
    
    // Events
    case TypingStarted          = "typing_started"
    case TypingStopped          = "typing_stopped"
    
    // Queries
    case FetchConversations     = "fetch_conversations"
    case ConversationDetails    = "fetch_conversation_details"
    case FetchConversationID    = "fetch_conversation_id"
    case FetchMessages          = "fetch_messages"
    case FetchMessagesNewerThan = "fetch_messages_newer_than_id"
    case FetchMessagesOlderThan = "fetch_messages_older_than_id"
    case Ping                   = "ping"
    
    enum RequestSuperType {
        case command
        case event
        case query
    }
    
    var superType: RequestSuperType {
        switch self {
        case .Authenticate, .SendMessage, .ConfirmReception, .ConfirmRead, .ArchiveConversations,
        .UnarchiveConversations:
            return .command
        case .TypingStarted, .TypingStopped:
            return .event
        case .FetchConversations, .ConversationDetails, .FetchConversationID, .FetchMessages, .FetchMessagesNewerThan,
        .FetchMessagesOlderThan, .Ping:
            return .query
        }
    }
}

struct WebSocketRouter {
    static func requestWith(_ id: String, type: WebSocketRequestType, data: [String : Any]?) -> String {
        var dict: [String : Any] = [:]
        dict["id"] = id
        dict["type"] = type.rawValue
        dict["data"] = data
        guard let JSONData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
            let JSONText = String(data: JSONData, encoding: .utf8)
            else { return "" }
        return String(JSONText)
    }
}
