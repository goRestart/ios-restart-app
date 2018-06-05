//
//  WebSocketRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


enum WebSocketRequestType: String {
    
    // Commands
    case authenticate = "authenticate"
    case sendMessage = "send_message"
    case confirmReception = "confirm_reception"
    case confirmRead = "confirm_read"
    case archiveConversations = "archive_conversations"
    case unarchiveConversations = "unarchive_conversations"
    case archiveInactiveConversations = "archive_inactive_conversations"
    case markAllConversationsAsRead = "mark_conversations_as_read"
    
    // Events
    case typingStarted = "typing_started"
    case typingStopped = "typing_stopped"
    
    // Queries
    case fetchConversations = "fetch_conversations"
    case fetchConversationDetails = "fetch_conversation_details"
    case fetchConversationID = "fetch_conversation_id"
    case fetchInactiveConversationsCount = "fetch_inactive_conversations_count"
    case fetchInactiveConversations = "fetch_inactive_conversations"
    case fetchMessages = "fetch_messages"
    case fetchMessagesNewerThan = "fetch_messages_newer_than_id"
    case fetchMessagesOlderThan = "fetch_messages_older_than_id"
    case ping = "ping"
    
    enum RequestSuperType {
        case command
        case event
        case query
    }
    
    var superType: RequestSuperType {
        switch self {
        case .authenticate, .sendMessage, .confirmReception, .confirmRead, .archiveConversations,
             .unarchiveConversations, .archiveInactiveConversations, .markAllConversationsAsRead:
            return .command
        case .typingStarted, .typingStopped:
            return .event
        case .fetchConversations, .fetchConversationDetails, .fetchConversationID, .fetchMessages, .fetchMessagesNewerThan,
             .fetchMessagesOlderThan, .fetchInactiveConversationsCount, .fetchInactiveConversations, .ping:
            return .query
        }
    }
}

struct WebSocketRouter {
    static func request(with id: String, type: WebSocketRequestType, data: [String : Any]?, meta: [String : Any]? = nil) -> String {
        var dict: [String : Any] = [:]
        dict["id"] = id
        dict["type"] = type.rawValue
        dict["data"] = data
        if let meta = meta {
            dict["meta"] = meta
        }
        guard let JSONData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
            let JSONText = String(data: JSONData, encoding: .utf8)
            else { return "" }
        return String(JSONText)
    }
}

