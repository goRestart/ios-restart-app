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

    func set(listing: Listing, freePostingModeAllowed: Bool) -> Self {
        params.addListingParams(listing)
        params[.userToId] = listing.user.objectId
        params[.freePosting] = TrackerEvent.eventParameterFreePostingWithPrice(freePostingModeAllowed, price: listing.price).rawValue
        return self
    }
    func set(chatListing: ChatListing, freePostingModeAllowed: Bool) -> Self {
        params.addChatListingParams(chatListing)
        params[.freePosting] = TrackerEvent.eventParameterFreePostingWithPrice(freePostingModeAllowed, price: chatListing.price).rawValue
        return self
    }
    func set(messageType: EventParameterMessageType) -> Self {
        params[.messageType] = messageType.rawValue
        return self
    }
    func set(quickAnswerType: EventParameterQuickAnswerType?) -> Self {
        params[.quickAnswerType] = quickAnswerType?.rawValue
        let isQuickAnswer: EventParameterBoolean = quickAnswerType != nil ? .trueParameter : .falseParameter
        params[.quickAnswer] = isQuickAnswer.rawValue
        return self
    }
    func set(typePage: EventParameterTypePage) -> Self {
        params[.typePage] = typePage.rawValue
        return self
    }
    func set(interlocutorId: String?) -> Self {
        params[.userToId] = interlocutorId
        return self
    }
    func set(error: EventParameterChatError) -> Self {
        params[.errorDescription] = error.description
        params[.errorDetails] = error.details
        return self
    }
    func set(sellerRating: Float?) -> Self {
        params[.sellerUserRating] = sellerRating
        return self
    }
    func set(isBumpedUp: EventParameterBoolean) -> Self {
        params[.isBumpedUp] = isBumpedUp.rawValue
        return self
    }
}

