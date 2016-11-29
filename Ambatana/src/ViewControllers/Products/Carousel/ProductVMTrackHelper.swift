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
    private let tracker: Tracker
    private var featureFlags: FeatureFlaggeable

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

    func trackVisit(visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource) {
        trackHelper.trackVisit(visitUserAction, source: source)
    }

    func trackVisitMoreInfo() {
        trackHelper.trackVisitMoreInfo()
    }

    // MARK: Share

    func trackShareStarted(shareType: ShareType?, buttonPosition: EventParameterButtonPosition) {
        trackHelper.trackShareStarted(shareType, buttonPosition: buttonPosition)
    }

    func trackShareCompleted(shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        trackHelper.trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }
}


// MARK: - Share

extension ProductVMTrackHelper {
    func trackShareStarted(shareType: ShareType?, buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product, network: shareType?.trackingShareNetwork,
                                                     buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareCompleted(shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        let event: TrackerEvent?
        switch state {
        case .Completed:
            event = TrackerEvent.productShareComplete(product, network: shareType.trackingShareNetwork,
                                                      typePage: .ProductDetail)
        case .Failed:
            event = nil
        case .Cancelled:
            event = TrackerEvent.productShareCancel(product, network: shareType.trackingShareNetwork,
                                                    typePage: .ProductDetail)
        }
        if let event = event {
            tracker.trackEvent(event)
        }
    }
}


// MARK: - Tracking

extension ProductVMTrackHelper {

    func trackVisit(visitUserAction: ProductVisitUserAction, source: EventParameterProductVisitSource) {
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

    func trackMarkSoldCompleted(source: EventParameterSellSourceValue) {
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: product, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
        tracker.trackEvent(trackerEvent)
    }

    func trackMarkUnsoldCompleted() {
        let trackerEvent = TrackerEvent.productMarkAsUnsold(product)
        tracker.trackEvent(trackerEvent)
    }

    func trackSaveFavoriteCompleted() {
        let trackerEvent = TrackerEvent.productFavorite(product, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackChatWithSeller(source: EventParameterTypePage) {
        let trackerEvent = TrackerEvent.productDetailChatButton(product, typePage: source)
        tracker.trackEvent(trackerEvent)
    }

    func trackCommercializerStart() {
        let trackerEvent = TrackerEvent.commercializerStart(product.objectId, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackMessageSent(isFirstMessage: Bool, messageType: ChatMessageType) {
        let trackMessageType = messageType.trackingMessageType
        if isFirstMessage {
            let firstMessageEvent = TrackerEvent.firstMessage(product, messageType: trackMessageType,
                                                              typePage: .ProductDetail)
            tracker.trackEvent(firstMessageEvent)
        }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user, messageType: trackMessageType,
                                                            isQuickAnswer: .False, typePage: .ProductDetail)
        tracker.trackEvent(messageSentEvent)

    }

    func trackInterestedUsersBubble(number: Int, productId: String) {
        let interestedUsersEvent = TrackerEvent.productDetailInterestedUsers(number, productId: productId)
        tracker.trackEvent(interestedUsersEvent)
    }

    func trackMoreInfoRelatedItemsComplete(itemPosition: Int) {
        let event = TrackerEvent.moreInfoRelatedItemsComplete(product, itemPosition: itemPosition)
        tracker.trackEvent(event)
    }

    func trackMoreInfoRelatedItemsViewMore() {
        let event = TrackerEvent.moreInfoRelatedItemsViewMore(product)
        tracker.trackEvent(event)
    }
}
