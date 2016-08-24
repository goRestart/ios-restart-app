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

    func shareInEmail(buttonPosition: EventParameterButtonPosition) {
        trackHelper.shareInEmail(buttonPosition)
    }

    func shareInEmailCompleted() {
        trackHelper.shareInEmailCompleted()
    }

    func shareInEmailCancelled() {
        trackHelper.shareInEmailCancelled()
    }

    func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
        trackHelper.shareInFacebook(buttonPosition)
    }

    func shareInFBCompleted() {
        trackHelper.shareInFBCompleted()
    }

    func shareInFBCancelled() {
        trackHelper.shareInFBCancelled()
    }

    func shareInFBMessenger() {
        trackHelper.shareInFBMessenger()
    }

    func shareInFBMessengerCompleted() {
        trackHelper.shareInFBMessengerCompleted()
    }

    func shareInFBMessengerCancelled() {
        trackHelper.shareInFBMessengerCancelled()
    }

    func shareInWhatsApp() {
        trackHelper.shareInWhatsApp()
    }

    func shareInTwitter() {
        trackHelper.shareInTwitter()
    }

    func shareInTwitterCompleted() {
        trackHelper.shareInTwitterCompleted()
    }

    func shareInTwitterCancelled() {
        trackHelper.shareInTwitterCancelled()
    }

    func shareInTelegram() {
        trackHelper.shareInTelegram()
    }

    func shareInWhatsappActivity() {
        trackHelper.shareInWhatsappActivity()
    }

    func shareInTwitterActivity() {
        trackHelper.shareInTwitterActivity()
    }

    func shareInSMS() {
        trackHelper.shareInSMS()
    }

    func shareInSMSCompleted() {
        trackHelper.shareInSMSCompleted()
    }

    func shareInSMSCancelled() {
        trackHelper.shareInSMSCancelled()
    }

    func shareInCopyLink() {
        trackHelper.shareInCopyLink()
    }
}


// MARK: - Share

extension ProductVMTrackHelper {
    func shareInEmail(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product, network: .Email,
                                                     buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInEmailCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product, network: .Email,
                                                             typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInEmailCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product, network: .Email, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
        let trackerEvent = TrackerEvent.productShare(product, network: .Facebook,
                                                     buttonPosition: buttonPosition, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product, network: .Facebook,
                                                             typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product, network: .Facebook, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessenger() {
        let trackerEvent = TrackerEvent.productShare(product, network: .FBMessenger, buttonPosition: .Bottom,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product, network: .FBMessenger,
                                                             typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product, network: .FBMessenger,
                                                           typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsApp() {
        let trackerEvent = TrackerEvent.productShare(product, network: .Whatsapp, buttonPosition: .Bottom,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitter() {
        let trackerEvent = TrackerEvent.productShare(product, network: .Twitter, buttonPosition: .Bottom,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product, network: .Twitter, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product, network: .Twitter, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }


    func shareInTelegram() {
        let trackerEvent = TrackerEvent.productShare(product, network: .Telegram, buttonPosition: .Bottom,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsappActivity() {
        let trackerEvent = TrackerEvent.productShare(product, network: .Whatsapp, buttonPosition: .Top,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterActivity() {
        let trackerEvent = TrackerEvent.productShare(product, network: .Twitter, buttonPosition: .Top,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInSMS() {
        let trackerEvent = TrackerEvent.productShare(product, network: .SMS, buttonPosition: .Bottom,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInSMSCompleted() {
        let trackerEvent = TrackerEvent.productShareComplete(product, network: .SMS, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInSMSCancelled() {
        let trackerEvent = TrackerEvent.productShareCancel(product, network: .SMS, typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
    }

    func shareInCopyLink() {
        let trackerEvent = TrackerEvent.productShare(product, network: .CopyLink, buttonPosition: .Bottom,
                                                     typePage: .ProductDetail)
        tracker.trackEvent(trackerEvent)
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

    func trackDirectStickerSent() {
        let messageType = EventParameterMessageType.Sticker
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
