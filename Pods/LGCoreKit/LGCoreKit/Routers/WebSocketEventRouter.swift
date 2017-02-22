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
    
    func typingStarted(_ conversationId: String) -> WebSocketEventRequest {
        let uuid = uuidGenerator.UUIDString
        let data: [String:Any]? = ["conversation_id": conversationId]
        let message = WebSocketRouter.request(with: uuid, type: .typingStarted, data: data)
        return WebSocketEventRequest(message: message, uuid: uuid, type: .typingStarted)
    }
    
    func typingStopped(_ conversationId: String) -> WebSocketEventRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId]
        let message = WebSocketRouter.request(with: uuid, type: .typingStopped, data: data)
        return WebSocketEventRequest(message: message, uuid: uuid, type: .typingStopped)
    }
}
