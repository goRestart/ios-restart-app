//
//  SendMessageTrackingInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class SendMessageTrackingInfo {
    private(set) var params = EventParameters()

    @discardableResult
    func set(listing: Listing, freePostingModeAllowed: Bool) -> Self {
        params.addListingParams(listing)
        params[.userToId] = listing.user.objectId
        params[.freePosting] = TrackerEvent.eventParameterFreePostingWithPrice(freePostingModeAllowed, price: listing.price).rawValue
        return self
    }

    @discardableResult
    func set(chatListing: ChatListing, freePostingModeAllowed: Bool) -> Self {
        params.addChatListingParams(chatListing)
        params[.freePosting] = TrackerEvent.eventParameterFreePostingWithPrice(freePostingModeAllowed, price: chatListing.price).rawValue
        return self
    }

    @discardableResult
    func set(messageType: EventParameterMessageType) -> Self {
        params[.messageType] = messageType.rawValue
        return self
    }

    @discardableResult
    func set(quickAnswerType: EventParameterQuickAnswerType?) -> Self {
        params[.quickAnswerType] = quickAnswerType?.rawValue
        let isQuickAnswer: EventParameterBoolean = quickAnswerType != nil ? .trueParameter : .falseParameter
        params[.quickAnswer] = isQuickAnswer.rawValue
        return self
    }

    @discardableResult
    func set(typePage: EventParameterTypePage) -> Self {
        params[.typePage] = typePage.rawValue
        return self
    }

    @discardableResult
    func set(interlocutorId: String?) -> Self {
        params[.userToId] = interlocutorId
        return self
    }

    @discardableResult
    func set(error: EventParameterChatError) -> Self {
        params[.errorDescription] = error.description
        params[.errorDetails] = error.details
        return self
    }

    @discardableResult
    func set(sellerRating: Float?) -> Self {
        params[.sellerUserRating] = sellerRating
        return self
    }

    @discardableResult
    func set(isBumpedUp: EventParameterBoolean) -> Self {
        params[.isBumpedUp] = isBumpedUp.rawValue
        return self
    }
}

