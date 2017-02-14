//
//  WebSocketCommandRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


struct WebSocketCommandRequest: WebSocketCommandRequestConvertible {
    var message: String
    var uuid: String
    var type: WebSocketRequestType
}

struct WebSocketCommandRouter {
    
    let uuidGenerator: UUIDGenerator
    
    func authenticate(_ userId: String, authToken: String) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["user_id": userId, "auth_token": authToken]
        let message = WebSocketRouter.request(with: uuid, type: .authenticate, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .authenticate)
    }
    
    func sendMessage(_ conversationId: String, messageId: String, type: String, text: String) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId, "message_id": messageId, "message_type": type, "text": text]
        let message = WebSocketRouter.request(with: uuid, type: .sendMessage, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .sendMessage)
    }
    
    func confirmReception(_ conversationId: String, messageIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_id": conversationId, "message_ids": messageIds]
        let message = WebSocketRouter.request(with: uuid, type: .confirmReception, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .confirmReception)
    }
    
    func confirmRead(_ conversationId: String, messageIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_id": conversationId, "message_ids": messageIds]
        let message = WebSocketRouter.request(with: uuid, type: .confirmRead, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .confirmRead)
    }
    
    func archiveConversations(_ conversationIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_ids": conversationIds]
        let message = WebSocketRouter.request(with: uuid, type: .archiveConversations, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .archiveConversations)
    }
    
    func unarchiveConversations(_ conversationIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_ids": conversationIds]
        let message = WebSocketRouter.request(with: uuid, type: .unarchiveConversations, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .unarchiveConversations)
    }
}
