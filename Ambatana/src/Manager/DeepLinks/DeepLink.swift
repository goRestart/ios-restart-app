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

    static func push(_ action: DeepLinkAction, origin: DeepLinkOrigin, campaign: String?, medium: String?,
                     source: DeepLinkSource) -> DeepLink {
        return DeepLink(action: action, origin: origin, campaign: campaign, medium: medium,
                        source: source)
    }

    static func link(_ action: DeepLinkAction, campaign: String?, medium: String?, source: DeepLinkSource) -> DeepLink {
        return DeepLink(action: action, origin: .link, campaign: campaign, medium: medium, source: source)
    }

    static func shortCut(_ action: DeepLinkAction) -> DeepLink {
        return DeepLink(action: action, origin: .shortCut, campaign: nil, medium: nil, source: .none)
    }
}

enum DeepLinkAction {
    case home
    case sell
    case product(productId: String)
    case user(userId: String)
    case conversations
    case conversation(data: ConversationData)
    case message(messageType: DeepLinkMessageType, data: ConversationData)
    case search(query: String, categories: String?)
    case resetPassword(token: String)
    case userRatings
    case userRating(ratingId: String)
    case passiveBuyers(productId: String)
}

enum DeepLinkOrigin {
    case push(appActive: Bool, alert: String)
    case link
    case shortCut

    var appActive: Bool {
        switch self {
        case .link, .shortCut:
            return false
        case let .push(appActive, _):
            return appActive
        }
    }

    var message: String {
        switch self {
        case .link, .shortCut:
            return ""
        case let .push(_, message):
            return message
        }
    }
}

enum DeepLinkSource {
    case external(source: String)
    case push
    case none

    init(string: String?) {
        guard let string = string else {
            self = .none
            return
        }
        self = .external(source: string)
    }
}

/**
 Enum to distinguish between the two methods to obtain a conversation

 - Conversation: By conversation id
 - ProductBuyer: By productId and buyerId 
 */
enum ConversationData {
    case conversation(conversationId: String)
    case productBuyer(productId: String, buyerId: String)
}

protocol ConversationDataDisplayer {
    func isDisplayingConversationData(_ data: ConversationData) -> Bool
}

/**
 Message type enum

 - Message: Typical message
 - Offer:   Message from an offer
 */
enum DeepLinkMessageType: Int {
    case message = 0
    case offer = 1
    case sticker = 2
}
