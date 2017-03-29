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
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productShare(product, network: shareType?.trackingShareNetwork,
                                                     buttonPosition: buttonPosition, typePage: .productDetail,
                                                     isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        let event: TrackerEvent?
        guard let product = listing.product else { return }
        switch state {
        case .completed:
            event = TrackerEvent.productShareComplete(product, network: shareType.trackingShareNetwork,
                                                      typePage: .productDetail)
        case .failed:
            event = nil
        case .cancelled:
            event = TrackerEvent.productShareCancel(product, network: shareType.trackingShareNetwork,
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
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productBumpUpStart(product, price: price)
        tracker.trackEvent(trackerEvent)
    }

    func trackBumpUpCompleted(_ price: EventParameterBumpUpPrice, network: EventParameterShareNetwork) {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productBumpUpComplete(product, price: price, network: network)
        tracker.trackEvent(trackerEvent)
    }
}


// MARK: - Tracking

extension ProductVMTrackHelper {

    func trackVisit(_ visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource, feedPosition: EventParameterFeedPosition, isShowingFeaturedStripe: EventParameterBoolean) {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productDetailVisit(product, visitUserAction: visitUserAction, source: source, feedPosition: feedPosition, isBumpedUp: isShowingFeaturedStripe)
        tracker.trackEvent(trackerEvent)
    }

    func trackVisitMoreInfo() {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productDetailVisitMoreInfo(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackReportCompleted() {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productReport(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteStarted() {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productDeleteStart(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteCompleted() {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productDeleteComplete(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkSoldCompleted(to userSoldTo: EventParameterUserSoldTo, isShowingFeaturedStripe: Bool) {
        guard let product = listing.product else { return }
        let isBumpedUp: EventParameterBoolean = isShowingFeaturedStripe ? .trueParameter : .falseParameter
        let trackerEvent = TrackerEvent.productMarkAsSold(product, typePage: .productDetail,
                                                          soldTo: featureFlags.userRatingMarkAsSold ? userSoldTo : nil,
                                                          freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                          isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkUnsoldCompleted() {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productMarkAsUnsold(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackSaveFavoriteCompleted(_ isShowingFeaturedStripe: Bool) {
        guard let product = listing.product else { return }
        let isBumpedUp = isShowingFeaturedStripe ? EventParameterBoolean.trueParameter :
            EventParameterBoolean.falseParameter
        let trackerEvent = TrackerEvent.productFavorite(product, typePage: .productDetail, isBumpedUp: isBumpedUp)
        tracker.trackEvent(trackerEvent)
    }

    func trackChatWithSeller(_ source: EventParameterTypePage) {
        guard let product = listing.product else { return }
        let trackerEvent = TrackerEvent.productDetailOpenChat(product, typePage: source)
        tracker.trackEvent(trackerEvent)
    }

    func trackCommercializerStart() {
        let trackerEvent = TrackerEvent.commercializerStart(listing.objectId, typePage: .productDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackMessageSent(_ isFirstMessage: Bool, messageType: ChatWrapperMessageType, isShowingFeaturedStripe: Bool) {
        guard let product = listing.product else { return }
        if isFirstMessage {
            let isBumpedUp = isShowingFeaturedStripe ? EventParameterBoolean.trueParameter :
                                                       EventParameterBoolean.falseParameter
            let firstMessageEvent = TrackerEvent.firstMessage(product, messageType: messageType.chatTrackerType, quickAnswerType: messageType.quickAnswerType,
                                                              typePage: .productDetail, freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                              isBumpedUp: isBumpedUp)
            tracker.trackEvent(firstMessageEvent)
        }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: listing.user, messageType: messageType.chatTrackerType, quickAnswerType: messageType.quickAnswerType,
                                                            typePage: .productDetail, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
        tracker.trackEvent(messageSentEvent)
    }
}
