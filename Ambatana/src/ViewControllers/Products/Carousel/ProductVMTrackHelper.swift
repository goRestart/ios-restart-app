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

    convenience init(product: Product) {
        self.init(tracker: TrackerProxy.sharedInstance, product: product)
    }

    init(tracker: Tracker, product: Product) {
        self.tracker = tracker
        self.product = product
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

    func trackShareStarted(shareType: ShareType, buttonPosition: EventParameterButtonPosition) {
        trackHelper.trackShareStarted(shareType, buttonPosition: buttonPosition)
    }

    func trackShareCompleted(shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        trackHelper.trackShareCompleted(shareType, buttonPosition: buttonPosition, state: state)
    }
}


// MARK: - Share

private extension ShareType {
    var shareNetwork: EventParameterShareNetwork {
        switch self {
        case .Email:
            return .Email
        case .Facebook:
            return .Facebook
        case .FBMessenger:
            return .FBMessenger
        case .Whatsapp:
            return .Whatsapp
        case .Twitter:
            return .Twitter
        case .Telegram:
            return .Telegram
        case .CopyLink:
            return .CopyLink
        case .SMS:
            return .SMS
        case .Native:
            return .Native
        }
    }
}

extension ProductVMTrackHelper {
    func trackShareStarted(shareType: ShareType, buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product, network: shareType.shareNetwork,
                                                     buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func trackShareCompleted(shareType: ShareType, buttonPosition: EventParameterButtonPosition, state: SocialShareState) {
        let event: TrackerEvent?
        switch state {
        case .Completed:
            event = TrackerEvent.productShareComplete(product, network: shareType.shareNetwork,
                                                      typePage: .ProductDetail)
        case .Failed:
            event = nil
        case .Cancelled:
            event = TrackerEvent.productShareCancel(product, network: shareType.shareNetwork,
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
        let trackerEvent = TrackerEvent.productMarkAsSold(source, product: product)
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

    func trackDirectMessageSent() {
        let messageType = EventParameterMessageType.Text
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, messageType: messageType,
                                                               typePage: .ProductDetail)
        tracker.trackEvent(askQuestionEvent)
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user,
                                                            messageType: messageType, isQuickAnswer: .False)
        tracker.trackEvent(messageSentEvent)
    }

    func trackDirectStickerSent(favorite: Bool) {
        let messageType = favorite ? EventParameterMessageType.Favorite : EventParameterMessageType.Sticker
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, messageType: messageType,
                                                               typePage: .ProductDetail)
        tracker.trackEvent(askQuestionEvent)
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: product.user,
                                                            messageType: messageType, isQuickAnswer: .False)
        tracker.trackEvent(messageSentEvent)
    }

    func trackInterestedUsersBubble(number: Int, productId: String) {
        let interestedUsersEvent = TrackerEvent.productDetailInterestedUsers(number, productId: productId)
        tracker.trackEvent(interestedUsersEvent)
    }
}
