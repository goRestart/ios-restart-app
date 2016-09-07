//
//  WebSocketEventRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


struct WebSocketEventRequest: WebSocketEventRequestConvertible {
    var message: String
    var uuid: String
    var type: WebSocketRequestType
}

struct WebSocketEventRouter {
    
    let uuidGenerator: UUIDGenerator
    
    func typingStarted(conversationId: String) -> WebSocketEventRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId]
        let message = WebSocketRouter.requestWith(uuid, type: .TypingStarted, data: data)
        return WebSocketEventRequest(message: message, uuid: uuid, type: .TypingStarted)
    }
    
    func typingStopped(conversationId: String) -> WebSocketEventRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId]
        let message = WebSocketRouter.requestWith(uuid, type: .TypingStopped, data: data)
        return WebSocketEventRequest(message: message, uuid: uuid, type: .TypingStopped)
    }
}
