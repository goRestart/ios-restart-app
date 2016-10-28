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
    var productId: String
    var isMyVideo: Bool
    var source: EventParameterTypePage
    var selectedCommercial: Commercializer? {
        didSet {
            guard let shareUrl = selectedCommercial?.shareURL else { return }
            socialShareMessage = CommercializerSocialMessage(shareUrl: shareUrl, thumbUrl: selectedCommercial?.thumbURL)
        }
    }
    var numberOfCommercials: Int {
        return commercialsList.count
    }
    var socialShareMessage: SocialMessage?
    private let tracker: Tracker = TrackerProxy.sharedInstance

    // Tracking var
    var templateIdsString: String = ""

    // MARK: - Lifercycle

    public init?(commercializers: [Commercializer], productId: String?, source: EventParameterTypePage, isMyVideo: Bool) {
        self.commercialsList = commercializers
        self.productId = productId ?? ""
        self.source = source
        self.isMyVideo = isMyVideo
        super.init()
        if commercializers.isEmpty { return nil }
    }


    // MARK: - public funcs

    func viewLoaded() {

        let templateIds: [String] = commercialsList.flatMap { $0.templateId }
        templateIdsString = templateIds.joinWithSeparator(",")

        let event = TrackerEvent.commercializerOpen(productId, typePage: source, template: templateIdsString)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func selectCommercialAtIndex(index: Int) {
        guard 0..<numberOfCommercials ~= index else { return }
        selectedCommercial = commercialsList[index]
    }

    func videoUrlAtIndex(index: Int) -> NSURL? {
        guard let videoUrl = commercialsList[index].videoLowURL else { return nil }
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


// MARK: - SocialShareViewDelegate - Share tracking

extension CommercialDisplayViewModel {

    var sharedTemplateId: String {
        return selectedCommercial?.templateId ?? ""
    }

    func didShareInEmail() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .Email)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInEmailCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPlayer,
                                                             template: sharedTemplateId, shareNetwork: .Email)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInFacebook() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInFBCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(event)

    }

    func didShareInFBMessenger() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInFBMessengerCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPlayer,
                                                             template: sharedTemplateId, shareNetwork: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInWhatsApp() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .Whatsapp)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInTwitter() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .Twitter)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInTwitterCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPlayer,
                                                             template: sharedTemplateId, shareNetwork: .Twitter)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInTelegram() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .Telegram)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func didShareInSMS() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .SMS)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func didShareInSMSCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPlayer,
                                                             template: sharedTemplateId, shareNetwork: .SMS)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func didShareInCopyLink() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId, shareNetwork: .CopyLink)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}
