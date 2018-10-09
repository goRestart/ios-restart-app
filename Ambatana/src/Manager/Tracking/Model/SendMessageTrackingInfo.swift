//
//  SendMessageTrackingInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 10/04/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

final class SendMessageTrackingInfo {
    private(set) var params = EventParameters()

    @discardableResult
    func set(listing: Listing) -> Self {
        params.addListingParams(listing)
        params[.userToId] = listing.user.objectId
        params[.freePosting] = listing.price.allowFreeFilters().rawValue
        return self
    }

    @discardableResult
    func set(chatListing: ChatListing) -> Self {
        params.addChatListingParams(chatListing)
        params[.freePosting] = chatListing.price.allowFreeFilters().rawValue
        return self
    }

    @discardableResult
    func set(messageType: EventParameterMessageType) -> Self {
        params[.messageType] = messageType.rawValue
        return self
    }
    
    @discardableResult
    func set(containsEmoji: Bool) -> Self {
        params[.chatContainsEmoji] = containsEmoji
        return self
    }

    @discardableResult
    func set(quickAnswerTypeParameter: String?) -> Self {
        params[.quickAnswerType] = quickAnswerTypeParameter
        let isQuickAnswer: EventParameterBoolean = quickAnswerTypeParameter != nil ? .trueParameter : .falseParameter
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

    func set(isVideo: EventParameterBoolean) -> Self {
        params[.isVideo] = isVideo.rawValue
        return self
    }

    @discardableResult
    func set(assistantMeeting: AssistantMeeting?, isSuggestedPlace: Bool?) -> Self {
        guard let assistantMeeting = assistantMeeting else { return self }
        params[.meetingMessageType] = EventParameterAssistantMeetingType(meetingMessageType: assistantMeeting.meetingType).rawValue
        params[.meetingDate] = assistantMeeting.date?.formattedForTracking() ?? TrackerEvent.notApply
        params[.meetingLocation] = assistantMeeting.locationName ?? TrackerEvent.notApply
        params[.suggestedLocation] = EventParameterBoolean(bool: isSuggestedPlace).rawValue
        return self
    }
    
    @discardableResult
    func set(isProfessional: Bool?) -> Self  {
        if let isProfessional = isProfessional {
            params[.listingType] = isProfessional ? EventParameterProductItemType.professional.rawValue : EventParameterProductItemType.real.rawValue
        } else {
            params[.listingType] = EventParameterProductItemType.privateOrProfessional.rawValue
        }
        return self
    }
}

extension SendMessageTrackingInfo {
    static func makeWith(type: ChatWrapperMessageType,
                         listing: Listing) -> SendMessageTrackingInfo {
        return SendMessageTrackingInfo()
            .set(listing: listing)
            .set(interlocutorId: listing.user.objectId)
            .set(messageType: type.chatTrackerType)
            .set(quickAnswerTypeParameter: type.quickAnswerTypeParameter)
    }
}
