//
//  WebSocketConversationRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public enum WebSocketConversationFilter: String {
    case none = "default"
    case asSeller = "as_seller"
    case asBuyer = "as_buyer"
    case archived = "archived"
}

struct WebSocketConversationRequest: WebSocketQueryRequestConvertible {
    var message: String
    var uuid: String
    var type: WebSocketRequestType
}

struct WebSocketConversationRouter {

    let uuidGenerator: UUIDGenerator

    func index(_ limit: Int = 50, offset: Int = 0, filter: WebSocketConversationFilter = .none)
        -> WebSocketConversationRequest {
            let uuid = uuidGenerator.UUIDString
            let data: [String: Any] = ["limit": limit, "offset": offset, "filter": filter.rawValue]
            let message = WebSocketRouter.requestWith(uuid, type: .FetchConversations, data: data)
            return WebSocketConversationRequest(message: message, uuid: uuid, type: .FetchConversations)
    }
    
    func show(_ conversationId: String) -> WebSocketConversationRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId]
        let message = WebSocketRouter.requestWith(uuid, type: .ConversationDetails, data: data)
        return WebSocketConversationRequest(message: message, uuid: uuid, type: .ConversationDetails)
    }
    
    func show(_ sellerId: String, productId: String) -> WebSocketConversationRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["seller_id": sellerId, "product_id": productId]
        let message = WebSocketRouter.requestWith(uuid, type: .FetchConversationID, data: data)
        return WebSocketConversationRequest(message: message, uuid: uuid, type: .FetchConversationID)
    }
}
