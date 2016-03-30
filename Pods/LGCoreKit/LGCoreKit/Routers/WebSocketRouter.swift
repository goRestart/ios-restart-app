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
    case CreateConversation     = "create_conversation"
    case FetchMessages          = "fetch_messages"
    case FetchMessagesNewerThan = "fetch_messages_newer_than_id"
    case FetchMessagesOlderThan = "fetch_messages_older_than_id"
    
    enum RequestSuperType {
        case Command
        case Event
        case Query
    }
    
    var superType: RequestSuperType {
        switch self {
        case .Authenticate, .SendMessage, .ConfirmReception, .ConfirmRead, .ArchiveConversations,
        .UnarchiveConversations:
            return .Command
        case .TypingStarted, .TypingStopped:
            return .Event
        case .FetchConversations, .ConversationDetails, .CreateConversation, .FetchMessages, .FetchMessagesNewerThan,
        .FetchMessagesOlderThan:
            return .Query
        }
    }
}

struct WebSocketRouter {
    static func requestWith(id: String, type: WebSocketRequestType, data: [String : AnyObject]) -> String {
        let dict = ["id" : id, "type" : type.rawValue, "data": data]
        guard let JSONData = try? NSJSONSerialization.dataWithJSONObject(dict, options: [.PrettyPrinted]),
            let JSONText = NSString(data: JSONData, encoding: NSASCIIStringEncoding)
            else { return "" }
        return String(JSONText)
    }
}
