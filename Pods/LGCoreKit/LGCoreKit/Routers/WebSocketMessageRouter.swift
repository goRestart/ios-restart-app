//
//  WebSocketMessageRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


struct WebSocketMessageRequest: WebSocketQueryRequestConvertible {
    var message: String
    var uuid: String
    var type: WebSocketRequestType
}

struct WebSocketMessageRouter {
    
    let uuidGenerator: UUIDGenerator

    func index(_ conversationId: String, limit: Int = 50, offset: Int = 0) -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_id": conversationId, "limit": limit, "offset": offset]
        let message = WebSocketRouter.request(with: uuid, type: .fetchMessages, data: data)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .fetchMessages)
    }
    
    func indexNewerThan(_ messageId: String, conversationId: String) -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId, "message_id": messageId]
        let message = WebSocketRouter.request(with: uuid, type: .fetchMessagesNewerThan, data: data)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .fetchMessagesNewerThan)
    }
    
    func indexOlderThan(_ messageId: String, conversationId: String, limit: Int = 50) -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_id": conversationId, "message_id": messageId, "limit": limit]
        let message = WebSocketRouter.request(with: uuid, type: .fetchMessagesOlderThan, data: data)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .fetchMessagesOlderThan)
    }
    
    func pingMessage() -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let message = WebSocketRouter.request(with: uuid, type: .ping, data: nil)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .ping)
    }
}
