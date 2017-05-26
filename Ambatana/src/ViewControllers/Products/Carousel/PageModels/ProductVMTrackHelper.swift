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


// MARK: - ProductViewModel trackings extension

extension ProductViewModel {

    func trackVisit(_ visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource, feedPosition: EventParameterFeedPosition) {
        let isBumpedUp = isShowingFeaturedStripe.value ? EventParameterBoolean.trueParameter :
                                                   EventParameterBoolean.falseParameter
        trackHelper.trackVisit(visitUserAction, source: source, feedPosition: feedPosition, isShowingFeaturedStripe: isBumpedUp)
    }

    func trackVisitMoreInfo() {
        trackHelper.trackVisitMoreInfo()
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

    func trackBumpUpStarted(_ price: EventParameterBumpUpPrice) {
        trackHelper.trackBumpUpStarted(price)
    }

    func trackBumpUpCompleted(_ price: EventParameterBumpUpPrice, network: EventParameterShareNetwork) {
        trackHelper.trackBumpUpCompleted(price, network: network)
    }
}


// MARK: - Share

extension ProductVMTrackHelper {
    func trackShareStarted(_ shareType: ShareType?, buttonPosition: EventParameterButtonPosition,
                           isBumpedUp: EventParameterBoolean) {
        let trackerEvent = TrackerEvent.productShare(listing, network: shareType?.trackingShareNetwork,
                                                     buttonPosition: buttonPosition, typePage: .productDetail,
                                                     isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        let event: TrackerEvent?
        switch state {
        case .completed:
            event = TrackerEvent.productShareComplete(listing, network: shareType.trackingShareNetwork,
                                                      typePage: .productDetail)
        case .failed:
            event = nil
        case .cancelled:
            event = TrackerEvent.productShareCancel(listing, network: shareType.trackingShareNetwork,
                                                    typePage: .productDetail)
        }
        if let event = event {
            tracker.trackEvent(event)
        }
    }
}


// MARK: - Bump Up

extension ProductVMTrackHelper {
    func trackBumpUpStarted(_ price: EventParameterBumpUpPrice) {
        let trackerEvent = TrackerEvent.productBumpUpStart(listing, price: price)
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpCompleted(_ price: EventParameterBumpUpPrice, network: EventParameterShareNetwork) {
        let trackerEvent = TrackerEvent.productBumpUpComplete(listing, price: price, network: network)
        tracker.trackEvent(trackerEvent)
    }
}


// MARK: - Tracking

extension ProductVMTrackHelper {

    func trackVisit(_ visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource, feedPosition: EventParameterFeedPosition, isShowingFeaturedStripe: EventParameterBoolean) {
        let trackerEvent = TrackerEvent.productDetailVisit(listing, visitUserAction: visitUserAction, source: source, feedPosition: feedPosition, isBumpedUp: isShowingFeaturedStripe)
        tracker.trackEvent(trackerEvent)
    }

    func trackVisitMoreInfo() {
        let trackerEvent = TrackerEvent.productDetailVisitMoreInfo(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackReportCompleted() {
        let trackerEvent = TrackerEvent.productReport(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteStarted() {
        let trackerEvent = TrackerEvent.productDeleteStart(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteCompleted() {
        let trackerEvent = TrackerEvent.productDeleteComplete(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkSoldCompleted(isShowingFeaturedStripe: Bool) {
        let isBumpedUp: EventParameterBoolean = isShowingFeaturedStripe ? .trueParameter : .falseParameter
        let trackerEvent = TrackerEvent.productMarkAsSold(listing, typePage: .productDetail,
                                                          freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                          isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkUnsoldCompleted() {
        let trackerEvent = TrackerEvent.productMarkAsUnsold(listing)
        tracker.trackEvent(trackerEvent)
    }

    func trackSaveFavoriteCompleted(_ isShowingFeaturedStripe: Bool) {
        let isBumpedUp = isShowingFeaturedStripe ? EventParameterBoolean.trueParameter :
            EventParameterBoolean.falseParameter
        let trackerEvent = TrackerEvent.productFavorite(listing, typePage: .productDetail, isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackChatWithSeller(_ source: EventParameterTypePage) {
        let trackerEvent = TrackerEvent.productDetailOpenChat(listing, typePage: source)
        tracker.trackEvent(trackerEvent)
    }

    func trackCommercializerStart() {
        let trackerEvent = TrackerEvent.commercializerStart(listing.objectId, typePage: .productDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackMessageSent(isFirstMessage: Bool, messageType: ChatWrapperMessageType, isShowingFeaturedStripe: Bool,
                          productVisitSource: EventParameterProductVisitSource) {
        guard let info = buildSendMessageInfo(withType: messageType, isShowingFeaturedStripe: isShowingFeaturedStripe,
                                              error: nil) else { return }
        if isFirstMessage {
            tracker.trackEvent(TrackerEvent.firstMessage(info: info, productVisitSource: productVisitSource))
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
            .set(typePage: .productDetail)
            .set(isBumpedUp: isBumpedUp)
        if let error = error {
            sendMessageInfo.set(error: error.chatError)
        }
        return sendMessageInfo
    }
}
