//
//  DeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

enum DeepLink {
    case Home
    case Sell
    case Product(productId: String)
    case User(userId: String)
    case Conversations
    case Conversation(data: ConversationData)
    case Message(messageType: MessageType, data: ConversationData)
    case Search(query: String, categories: String?)
    case ResetPassword(token: String)
}


/**
 Enum to distinguish between the two methods to obtain a conversation

 - Conversation: By conversation id
 - ProductBuyer: By productId and buyerId 
 */
enum ConversationData {
    case Conversation(conversationId: String)
    case ProductBuyer(productId: String, buyerId: String)

    var conversationId: String? {
        switch self {
        case .Conversation(let conversationId):
            return conversationId
        default:
            return nil
        }
    }

    var productId: String? {
        switch self {
        case .ProductBuyer(let productId, _):
            return productId
        default:
            return nil
        }
    }

    var buyerId: String? {
        switch self {
        case .ProductBuyer(_, let buyerId):
            return buyerId
        default:
            return nil
        }
    }
}


/**
 Message type enum

 - Message: Typical message
 - Offer:   Message from an offer
 */
enum MessageType: Int {
    case Message = 0
    case Offer = 1
}