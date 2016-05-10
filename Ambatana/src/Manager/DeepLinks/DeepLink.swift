//
//  DeepLink.swift
//  LetGo
//
//  Created by Eli Kohen on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

struct DeepLink {
    let action: DeepLinkAction
    let origin: DeepLinkOrigin

    static func push(action: DeepLinkAction, appActive: Bool) -> DeepLink {
        return DeepLink(action: action, origin: .Push(appActive: appActive))
    }

    static func link(action: DeepLinkAction) -> DeepLink {
        return DeepLink(action: action, origin: .Link)
    }

    static func shortCut(action: DeepLinkAction) -> DeepLink {
        return DeepLink(action: action, origin: .ShortCut)
    }
}

enum DeepLinkAction {
    case Home
    case Sell
    case Product(productId: String)
    case User(userId: String)
    case Conversations
    case Conversation(data: ConversationData)
    case Message(messageType: MessageType, data: ConversationData)
    case Search(query: String, categories: String?)
    case ResetPassword(token: String)
    case Commercializer(productId: String, templateId: String)
    case CommercializerReady(productId: String, templateId: String)
}

enum DeepLinkOrigin {
    case Push(appActive: Bool)
    case Link
    case ShortCut
}


/**
 Enum to distinguish between the two methods to obtain a conversation

 - Conversation: By conversation id
 - ProductBuyer: By productId and buyerId 
 */
enum ConversationData {
    case Conversation(conversationId: String)
    case ProductBuyer(productId: String, buyerId: String)
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
