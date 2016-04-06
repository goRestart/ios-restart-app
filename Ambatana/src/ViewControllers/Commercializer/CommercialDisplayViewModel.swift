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
            guard let shareUrl = selectedCommercial?.videoLowURL else { return }
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


// MARK: - Share tracking

extension CommercialDisplayViewModel {

    // TODO: will be filled at ABIOS-1122

    func shareInEmail(buttonPosition: EventParameterButtonPosition) {
    }

    func shareInFacebook(buttonPosition: EventParameterButtonPosition) {
    }

    func shareInFBCompleted() {
    }

    func shareInFBCancelled() {
    }

    func shareInFBMessenger() {
    }

    func shareInFBMessengerCompleted() {
    }

    func shareInFBMessengerCancelled() {
    }

    func shareInWhatsApp() {
    }

    func shareInTwitter() {
    }

    func shareInTwitterCompleted() {
    }

    func shareInTwitterCancelled() {
    }

    func shareInTelegram() {
    }
}
