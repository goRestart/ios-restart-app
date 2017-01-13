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
        let message = WebSocketRouter.requestWith(uuid, type: .FetchMessages, data: data)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .FetchMessages)
    }
    
    func indexNewerThan(_ messageId: String, conversationId: String) -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId, "message_id": messageId]
        let message = WebSocketRouter.requestWith(uuid, type: .FetchMessagesNewerThan, data: data)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .FetchMessagesNewerThan)
    }
    
    func indexOlderThan(_ messageId: String, conversationId: String, limit: Int = 50) -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String: Any] = ["conversation_id": conversationId, "message_id": messageId, "limit": limit]
        let message = WebSocketRouter.requestWith(uuid, type: .FetchMessagesOlderThan, data: data)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .FetchMessagesOlderThan)
    }
    
    func pingMessage() -> WebSocketMessageRequest {
        let uuid = uuidGenerator.UUIDString
        let message = WebSocketRouter.requestWith(uuid, type: .Ping, data: nil)
        return WebSocketMessageRequest(message: message, uuid: uuid, type: .Ping)
    }
}
