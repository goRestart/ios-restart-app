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
    
    func authenticate(userId: String, authToken: String) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["user_id": userId, "auth_token": authToken]
        let message = WebSocketRouter.requestWith(uuid, type: .Authenticate, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .Authenticate)
    }
    
    func sendMessage(conversationId: String, messageId: String, type: String, text: String) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId, "message_id": messageId, "message_type": type, "text": text]
        let message = WebSocketRouter.requestWith(uuid, type: .SendMessage, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .SendMessage)
    }
    
    func confirmReception(conversationId: String, messageIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: AnyObject] = ["conversation_id": conversationId, "message_ids": messageIds]
        let message = WebSocketRouter.requestWith(uuid, type: .ConfirmReception, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .ConfirmReception)
    }
    
    func confirmRead(conversationId: String, messageIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: AnyObject] = ["conversation_id": conversationId, "message_ids": messageIds]
        let message = WebSocketRouter.requestWith(uuid, type: .ConfirmRead, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .ConfirmRead)
    }
    
    func archiveConversations(conversationIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: AnyObject] = ["conversation_ids": conversationIds]
        let message = WebSocketRouter.requestWith(uuid, type: .ArchiveConversations, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .ArchiveConversations)
    }
    
    func unarchiveConversations(conversationIds: [String]) -> WebSocketCommandRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: AnyObject] = ["conversation_ids": conversationIds]
        let message = WebSocketRouter.requestWith(uuid, type: .UnarchiveConversations, data: data)
        return WebSocketCommandRequest(message: message, uuid: uuid, type: .UnarchiveConversations)
    }
}
