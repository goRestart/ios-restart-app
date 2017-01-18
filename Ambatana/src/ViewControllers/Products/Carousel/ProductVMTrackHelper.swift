//
//  ProductVMTrackHelper.swift
//  LetGo
//
//  Created by Eli Kohen on 09/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ProductVMTrackHelper {

    var product: Product
    fileprivate let tracker: Tracker
    fileprivate var featureFlags: FeatureFlaggeable

    convenience init(product: Product) {
        self.init(tracker: TrackerProxy.sharedInstance, product: product, featureFlags: FeatureFlags.sharedInstance)
    }

    init(tracker: Tracker, product: Product, featureFlags: FeatureFlaggeable) {
        self.tracker = tracker
        self.product = product
        self.featureFlags = featureFlags
    }
}


// MARK: - ProductViewModel trackings extension

extension ProductViewModel {

    func trackVisit(_ visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource) {
        trackHelper.trackVisit(visitUserAction, source: source)
    }

    func trackVisitMoreInfo() {
        trackHelper.trackVisitMoreInfo()
    }

    // MARK: Share

    func trackShareStarted(_ shareType: ShareType?, buttonPosition: EventParameterButtonPosition) {
        trackHelper.trackShareStarted(shareType, buttonPosition: buttonPosition)
    }

    func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        trackHelper.trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }
}


// MARK: - Share

extension ProductVMTrackHelper {
    func trackShareStarted(_ shareType: ShareType?, buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product, network: shareType?.trackingShareNetwork,
                                                     buttonPosition: buttonPosition, typePage: .productDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareCompleted(_ shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        let event: TrackerEvent?
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


// MARK: - Tracking

extension ProductVMTrackHelper {

    func trackVisit(_ visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource) {
        let trackerEvent = TrackerEvent.productDetailVisit(product, visitUserAction: visitUserAction, source: source)
        tracker.trackEvent(trackerEvent)
    }

    func trackVisitMoreInfo() {
        let trackerEvent = TrackerEvent.productDetailVisitMoreInfo(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackReportCompleted() {
        let trackerEvent = TrackerEvent.productReport(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteStarted() {
        let trackerEvent = TrackerEvent.productDeleteStart(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackDeleteCompleted() {
        let trackerEvent = TrackerEvent.productDeleteComplete(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkSoldCompleted(_ source: EventParameterSellSourceValue) {
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: product, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkUnsoldCompleted() {
        let trackerEvent = TrackerEvent.productMarkAsUnsold(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackSaveFavoriteCompleted() {
        let trackerEvent = TrackerEvent.productFavorite(product, typePage: .productDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackChatWithSeller(_ source: EventParameterTypePage) {
        let trackerEvent = TrackerEvent.productDetailOpenChat(product, typePage: source)
        tracker.trackEvent(trackerEvent)
    }

    func trackCommercializerStart() {
        let trackerEvent = TrackerEvent.commercializerStart(product.objectId, typePage: .productDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackMessageSent(_ isFirstMessage: Bool, messageType: EventParameterMessageType) {
        if isFirstMessage {
            let firstMessageEvent = TrackerEvent.firstMessage(product, messageType: messageType,
                                                              typePage: .productDetail)
            tracker.trackEvent(firstMessageEvent)
        }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user, messageType: messageType,
                                                            isQuickAnswer: .falseParameter, typePage: .productDetail)
        tracker.trackEvent(messageSentEvent)
    }

    func trackMoreInfoRelatedItemsComplete(_ itemPosition: Int) {
        let event = TrackerEvent.moreInfoRelatedItemsComplete(product, itemPosition: itemPosition)
        tracker.trackEvent(event)
    }

    func trackMoreInfoRelatedItemsViewMore() {
        let event = TrackerEvent.moreInfoRelatedItemsViewMore(product)
        tracker.trackEvent(event)
    }
}
