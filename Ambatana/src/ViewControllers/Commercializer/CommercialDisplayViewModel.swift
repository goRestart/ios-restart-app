//
//  CommercialDisplayViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit


public class CommercialDisplayViewModel: BaseViewModel {

    var commercialsList: [Commercializer]
    var selectedCommercial: Commercializer? {
        didSet {
            guard let shareUrl = selectedCommercial?.videoURL else { return }
            socialShareMessage = SocialHelper.socialMessageCommercializer(shareUrl, thumbUrl: selectedCommercial?.thumbURL)
        }
    }
    var numberOfCommercials: Int {
        return commercialsList.count
    }
    var socialShareMessage: SocialMessage?
    private let tracker: Tracker = TrackerProxy.sharedInstance


    // MARK: - Lifercycle

    public init?(commercializers: [Commercializer]) {
        self.commercialsList = commercializers
        super.init()
        if commercializers.isEmpty { return nil }
    }


    // MARK: - public funcs

    func selectCommercialAtIndex(index: Int) {
        guard 0..<numberOfCommercials ~= index else { return }
        selectedCommercial = commercialsList[index]
    }

    func videoUrlAtIndex(index: Int) -> NSURL? {
        guard let videoUrl = commercialsList[index].videoURL else { return nil }
        return NSURL(string: videoUrl)
    }

    func thumbUrlAtIndex(index: Int) -> NSURL? {
        guard let thumbUrl = commercialsList[index].thumbURL else { return nil }
        return NSURL(string: thumbUrl)
    }

    func shareUrlAtIndex(index: Int) -> NSURL? {
        guard let shareURL = commercialsList[index].shareURL else { return nil }
        return NSURL(string: shareURL)
    }
}


// MARK: - Share tracking

extension CommercialDisplayViewModel {

    func shareInEmail(buttonPosition: EventParameterButtonPosition) {
        //        let trackerEvent = TrackerEvent.productShare(product.value, network: .Email,
        //                                                     buttonPosition: buttonPosition, typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
        //        let trackerEvent = TrackerEvent.productShare(product.value, network: .Facebook,
        //                                                     buttonPosition: buttonPosition, typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCompleted() {
        //        let trackerEvent = TrackerEvent.productShareComplete(product.value, network: .Facebook,
        //                                                             typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInFBCancelled() {
        //        let trackerEvent = TrackerEvent.productShareCancel(product.value, network: .Facebook, typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessenger() {
        //        let trackerEvent = TrackerEvent.productShare(product.value, network: .FBMessenger, buttonPosition: .Bottom,
        //                                                     typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCompleted() {
        //        let trackerEvent = TrackerEvent.productShareComplete(product.value, network: .FBMessenger,
        //                                                             typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInFBMessengerCancelled() {
        //        let trackerEvent = TrackerEvent.productShareCancel(product.value, network: .FBMessenger,
        //                                                           typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInWhatsApp() {
        //        let trackerEvent = TrackerEvent.productShare(product.value, network: .Whatsapp, buttonPosition: .Bottom,
        //                                                     typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitter() {
        //        let trackerEvent = TrackerEvent.productShare(product.value, network: .Twitter, buttonPosition: .Bottom,
        //                                                     typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterCompleted() {
        //        let trackerEvent = TrackerEvent.productShareComplete(product.value, network: .Twitter, typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }

    func shareInTwitterCancelled() {
        //        let trackerEvent = TrackerEvent.productShareCancel(product.value, network: .Twitter, typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }
    
    
    func shareInTelegram() {
        //        let trackerEvent = TrackerEvent.productShare(product.value, network: .Telegram, buttonPosition: .Bottom,
        //                                                     typePage: .ProductDetail)
        //        tracker.trackEvent(trackerEvent)
    }
}
