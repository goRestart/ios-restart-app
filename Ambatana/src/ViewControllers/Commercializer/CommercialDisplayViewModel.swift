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
    var source: EventParameterTypePage
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


    // MARK: - Lifercycle

    public init?(commercializers: [Commercializer], productId: String?, source: EventParameterTypePage) {
        self.commercialsList = commercializers
        self.productId = productId ?? ""
        self.source = source
        super.init()
        if commercializers.isEmpty { return nil }
    }


    // MARK: - public funcs

    func viewLoaded() {

        let templateIds: [String] = commercialsList.map { $0.templateId }
        let templateIdsString = templateIds.joinWithSeparator(",")

        let event = TrackerEvent.commercializerOpen(productId, typePage: source, template: templateIdsString)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

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
