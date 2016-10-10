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
    let campaign: String?
    let medium: String?
    let source: DeepLinkSource

    static func push(action: DeepLinkAction, origin: DeepLinkOrigin, campaign: String?, medium: String?,
                     source: DeepLinkSource) -> DeepLink {
        return DeepLink(action: action, origin: origin, campaign: campaign, medium: medium,
                        source: source)
    }

    static func link(action: DeepLinkAction, campaign: String?, medium: String?, source: DeepLinkSource) -> DeepLink {
        return DeepLink(action: action, origin: .Link, campaign: campaign, medium: medium, source: source)
    }

    static func shortCut(action: DeepLinkAction) -> DeepLink {
        return DeepLink(action: action, origin: .ShortCut, campaign: nil, medium: nil, source: .None)
    }
}

enum DeepLinkAction {
    case Home
    case Sell
    case Product(productId: String)
    case User(userId: String)
    case Conversations
    case Conversation(data: ConversationData)
    case Message(messageType: DeepLinkMessageType, data: ConversationData)
    case Search(query: String, categories: String?)
    case ResetPassword(token: String)
    case Commercializer(productId: String, templateId: String)
    case CommercializerReady(productId: String, templateId: String)
    case UserRatings
    case UserRating(ratingId: String)
}

enum DeepLinkOrigin {
    case Push(appActive: Bool, alert: String)
    case Link
    case ShortCut

    var appActive: Bool {
        switch self {
        case .Link, .ShortCut:
            return false
        case let .Push(appActive, _):
            return appActive
        }
    }

    var message: String {
        switch self {
        case .Link, .ShortCut:
            return ""
        case let .Push(_, message):
            return message
        }
    }
}

enum DeepLinkSource {
    case External(source: String)
    case Push
    case None

    init(string: String?) {
        guard let string = string else {
            self = .None
            return
        }
        self = .External(source: string)
    }
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

protocol ConversationDataDisplayer {
    func isDisplayingConversationData(data: ConversationData) -> Bool
}

/**
 Message type enum

 - Message: Typical message
 - Offer:   Message from an offer
 */
enum DeepLinkMessageType: Int {
    case Message = 0
    case Offer = 1
    case Sticker = 2
}
