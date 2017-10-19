//
//  ProductVMTrackHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductVMTrackHelper {

    var listing: Listing
    fileprivate let tracker: Tracker
    fileprivate var featureFlags: FeatureFlaggeable

    init(tracker: Tracker, listing: Listing, featureFlags: FeatureFlaggeable) {
        self.tracker = tracker
        self.listing = listing
        self.featureFlags = featureFlags
    }
}


// MARK: - ListingViewModel trackings extension

extension ListingViewModel {

    func trackVisit(_ visitUserAction: ListingVisitUserAction, source: EventParameterListingVisitSource, feedPosition: EventParameterFeedPosition) {
        let isBumpedUp = isShowingFeaturedStripe.value ? EventParameterBoolean.trueParameter :
                                                   EventParameterBoolean.falseParameter
        trackHelper.trackVisit(visitUserAction, source: source, feedPosition: feedPosition, isShowingFeaturedStripe: isBumpedUp)
    }

    func trackVisitMoreInfo(isMine: EventParameterBoolean,
                            adShown: EventParameterBoolean,
                            queryType: EventParameterAdQueryType?,
                            query: String?,
                            visibility: EventParameterAdVisibility?,
                            errorReason: EventParameterAdSenseRequestErrorReason?) {
        trackHelper.trackVisitMoreInfo(isMine: isMine,
                                       adShown: adShown,
                                       queryType: queryType,
                                       query: query,
                                       visibility: visibility,
                                       errorReason: errorReason)
    }


    // MARK: Share

    func trackShareStarted(_ shareType: ShareType?, buttonPosition: EventParameterButtonPosition) {
        let isBumpedUp = isShowingFeaturedStripe.value ? EventParameterBoolean.trueParameter :
            EventParameterBoolean.falseParameter
        trackHelper.trackShareStarted(shareType, buttonPosition: buttonPosition, isBumpedUp: isBumpedUp)
    }

    func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        trackHelper.trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }

    // MARK: Bump Up

    func trackBumpUpBannerShown(type: BumpUpType) {
        trackHelper.trackBumpUpBannerShown(type: type)
    }

    func trackBumpUpStarted(_ price: EventParameterBumpUpPrice, type: BumpUpType) {
        trackHelper.trackBumpUpStarted(price, type: type)
    }

    func trackBumpUpCompleted(_ price: EventParameterBumpUpPrice, type: BumpUpType, restoreRetriesCount: Int,
                              network: EventParameterShareNetwork) {
        trackHelper.trackBumpUpCompleted(price, type: type, restoreRetriesCount: restoreRetriesCount, network: network)
    }

    func trackBumpUpFail(type: BumpUpType) {
        trackHelper.trackBumpUpFail(type: type)
    }

    func trackMobilePaymentComplete(withPaymentId paymentId: String) {
        trackHelper.trackMobilePaymentComplete(withPaymentId: paymentId)
    }

    func trackMobilePaymentFail(withReason reason: String?) {
        trackHelper.trackMobilePaymentFail(withReason: reason)
    }

    func trackBumpUpNotAllowed(reason: EventParameterBumpUpNotAllowedReason) {
        trackHelper.trackBumpUpNotAllowed(reason: reason)
    }

    func trackBumpUpNotAllowedContactUs(reason: EventParameterBumpUpNotAllowedReason) {
        trackHelper.trackBumpUpNotAllowedContactUs(reason: reason)
    }
}


// MARK: - Share

extension ProductVMTrackHelper {
    func trackShareStarted(_ shareType: ShareType?, buttonPosition: EventParameterButtonPosition,
                           isBumpedUp: EventParameterBoolean) {
        let trackerEvent = TrackerEvent.listingShare(listing, network: shareType?.trackingShareNetwork,
                                                     buttonPosition: buttonPosition, typePage: .listingDetail,
                                                     isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        let event: TrackerEvent?
        switch state {
        case .completed:
            event = TrackerEvent.listingShareComplete(listing, network: shareType.trackingShareNetwork,
                                                      typePage: .listingDetail)
        case .failed:
            event = nil
        case .cancelled:
            event = TrackerEvent.listingShareCancel(listing, network: shareType.trackingShareNetwork,
                                                    typePage: .listingDetail)
        }
        if let event = event {
            tracker.trackEvent(event)
        }
    }
}


// MARK: - Bump Up

extension ProductVMTrackHelper {
    func trackBumpUpBannerShown(type: BumpUpType) {
        let trackerEvent = TrackerEvent.bumpBannerShow(type: EventParameterBumpUpType(bumpType: type), listingId: listing.objectId)
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpStarted(_ price: EventParameterBumpUpPrice, type: BumpUpType) {
        let trackerEvent = TrackerEvent.listingBumpUpStart(listing, price: price,
                                                           type: EventParameterBumpUpType(bumpType: type))
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpCompleted(_ price: EventParameterBumpUpPrice, type: BumpUpType, restoreRetriesCount: Int, network: EventParameterShareNetwork) {
        let trackerEvent = TrackerEvent.listingBumpUpComplete(listing, price: price,
                                                              type: EventParameterBumpUpType(bumpType: type),
                                                              restoreRetriesCount: restoreRetriesCount,
                                                              network: network)
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpFail(type: BumpUpType) {
        let trackerEvent = TrackerEvent.listingBumpUpFail(type: EventParameterBumpUpType(bumpType: type), listingId: listing.objectId)
        tracker.trackEvent(trackerEvent)
    }

    func trackMobilePaymentComplete(withPaymentId paymentId: String) {
        let trackerEvent = TrackerEvent.mobilePaymentComplete(paymentId: paymentId, listingId: listing.objectId)
        tracker.trackEvent(trackerEvent)
    }

    func trackMobilePaymentFail(withReason reason: String?) {
        let trackerEvent = TrackerEvent.mobilePaymentFail(reason: reason, listingId: listing.objectId)
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpNotAllowed(reason: EventParameterBumpUpNotAllowedReason) {
        let trackerEvent = TrackerEvent.bumpUpNotAllowed(reason)
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpNotAllowedContactUs(reason: EventParameterBumpUpNotAllowedReason) {
        let trackerEvent = TrackerEvent.bumpUpNotAllowedContactUs(reason)
        tracker.trackEvent(trackerEvent)
    }
}


// MARK: - Tracking

extension ProductVMTrackHelper {

    func trackVisit(_ visitUserAction: ListingVisitUserAction, source: EventParameterListingVisitSource, feedPosition: EventParameterFeedPosition, isShowingFeaturedStripe: EventParameterBoolean) {
        let trackerEvent = TrackerEvent.listingDetailVisit(listing, visitUserAction: visitUserAction, source: source, feedPosition: feedPosition, isBumpedUp: isShowingFeaturedStripe)
        tracker.trackEvent(trackerEvent)
    }

    func trackVisitMoreInfo(isMine: EventParameterBoolean,
                            adShown: EventParameterBoolean,
                            queryType: EventParameterAdQueryType?,
                            query: String?,
                            visibility: EventParameterAdVisibility?,
                            errorReason: EventParameterAdSenseRequestErrorReason?) {

        let trackerEvent = TrackerEvent.listingDetailVisitMoreInfo(listing,
                                                                   isMine: isMine,
                                                                   adShown: adShown,
                                                                   queryType: queryType,
                                                                   query: query,
                                                                   visibility: visibility,
                                                                   errorReason: errorReason)
        tracker.trackEvent(trackerEvent)
    }

    func trackReportCompleted() {
        let trackerEvent = TrackerEvent.listingReport(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteStarted() {
        let trackerEvent = TrackerEvent.listingDeleteStart(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteCompleted() {
        let trackerEvent = TrackerEvent.listingDeleteComplete(listing)
        tracker.trackEvent(trackerEvent)
    }

    func makeMarkAsSoldTrackingInfo(isShowingFeaturedStripe: Bool) -> MarkAsSoldTrackingInfo {
        let isBumpedUp: EventParameterBoolean = isShowingFeaturedStripe ? .trueParameter : .falseParameter
        return MarkAsSoldTrackingInfo.make(listing: listing,
                                           isBumpedUp: isBumpedUp,
                                           isFreePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                           typePage: .listingDetail)
    }
    
    func trackMarkSoldCompleted(isShowingFeaturedStripe: Bool) {
        let trackingInfo = makeMarkAsSoldTrackingInfo(isShowingFeaturedStripe: isShowingFeaturedStripe)
        let markAsSold = TrackerEvent.listingMarkAsSold(trackingInfo: trackingInfo)
        tracker.trackEvent(markAsSold)
    }

    func trackMarkUnsoldCompleted() {
        let trackerEvent = TrackerEvent.listingMarkAsUnsold(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackSaveFavoriteCompleted(_ isShowingFeaturedStripe: Bool) {
        let isBumpedUp = isShowingFeaturedStripe ? EventParameterBoolean.trueParameter :
            EventParameterBoolean.falseParameter
        let trackerEvent = TrackerEvent.listingFavorite(listing, typePage: .listingDetail, isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackChatWithSeller(_ source: EventParameterTypePage) {
        let trackerEvent = TrackerEvent.listingDetailOpenChat(listing, typePage: source)
        tracker.trackEvent(trackerEvent)
    }

    func trackMessageSent(isFirstMessage: Bool,
                          messageType: ChatWrapperMessageType,
                          isShowingFeaturedStripe: Bool,
                          listingVisitSource: EventParameterListingVisitSource,
                          feedPosition: EventParameterFeedPosition) {
        guard let info = buildSendMessageInfo(withType: messageType,
                                              isShowingFeaturedStripe: isShowingFeaturedStripe,
                                              error: nil) else { return }
        if isFirstMessage {
            tracker.trackEvent(TrackerEvent.firstMessage(info: info,
                                                         listingVisitSource: listingVisitSource,
                                                         feedPosition: feedPosition))
        }
        tracker.trackEvent(TrackerEvent.userMessageSent(info: info))
    }

    func trackMessageSentError(messageType: ChatWrapperMessageType, isShowingFeaturedStripe: Bool, error: RepositoryError) {
        guard let info = buildSendMessageInfo(withType: messageType, isShowingFeaturedStripe: isShowingFeaturedStripe,
                                              error: error) else { return }
        tracker.trackEvent(TrackerEvent.userMessageSentError(info: info))
    }

    private func buildSendMessageInfo(withType messageType: ChatWrapperMessageType, isShowingFeaturedStripe: Bool,
                                      error: RepositoryError?) -> SendMessageTrackingInfo? {
        let isBumpedUp = isShowingFeaturedStripe ? EventParameterBoolean.trueParameter :
            EventParameterBoolean.falseParameter

        let sendMessageInfo = SendMessageTrackingInfo()
            .set(listing: listing, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
            .set(messageType: messageType.chatTrackerType)
            .set(quickAnswerType: messageType.quickAnswerType)
            .set(typePage: .listingDetail)
            .set(isBumpedUp: isBumpedUp)
        if let error = error {
            sendMessageInfo.set(error: error.chatError)
        }
        return sendMessageInfo
    }
}
