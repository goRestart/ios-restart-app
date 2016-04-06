//
//  WebSocketConversationRouter.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 17/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public enum WebSocketConversationFilter: String {
    case None = "default"
    case AsSeller = "as_seller"
    case asBuyer = "as_buyer"
    case Archived = "archived"
}

struct WebSocketConversationRequest: WebSocketQueryRequestConvertible {
    var message: String
    var uuid: String
    var type: WebSocketRequestType
}

struct WebSocketConversationRouter {

    let uuidGenerator: UUIDGenerator

    func index(limit: Int = 50, offset: Int = 0, filter: WebSocketConversationFilter = .None)
        -> WebSocketConversationRequest {
            let uuid = uuidGenerator.UUIDString
            let data: [String: AnyObject] = ["limit": limit, "offset": offset, "filter": filter.rawValue]
            let message = WebSocketRouter.requestWith(uuid, type: .FetchConversations, data: data)
            return WebSocketConversationRequest(message: message, uuid: uuid, type: .FetchConversations)
    }
    
    func show(conversationId: String) -> WebSocketConversationRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["conversation_id": conversationId]
        let message = WebSocketRouter.requestWith(uuid, type: .ConversationDetails, data: data)
        return WebSocketConversationRequest(message: message, uuid: uuid, type: .ConversationDetails)
    }
    
    func show(sellerId: String, productId: String) -> WebSocketConversationRequest {
        let uuid = uuidGenerator.UUIDString
        let data = ["seller_id": sellerId, "product_id": productId]
        let message = WebSocketRouter.requestWith(uuid, type: .FetchConversationID, data: data)
        return WebSocketConversationRequest(message: message, uuid: uuid, type: .FetchConversationID)
    }
}
