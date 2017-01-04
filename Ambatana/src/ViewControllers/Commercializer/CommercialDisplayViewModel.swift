//
//  CommercialDisplayViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/03/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit


class CommercialDisplayViewModel: BaseViewModel {

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
        templateIdsString = templateIds.joined(separator: ",")

        let event = TrackerEvent.commercializerOpen(productId, typePage: source, template: templateIdsString)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func selectCommercialAtIndex(_ index: Int) {
        guard 0..<numberOfCommercials ~= index else { return }
        selectedCommercial = commercialsList[index]
    }

    func videoUrlAtIndex(_ index: Int) -> URL? {
        guard let videoUrl = commercialsList[index].videoLowURL else { return nil }
        return URL(string: videoUrl)
    }

    func thumbUrlAtIndex(_ index: Int) -> URL? {
        guard let thumbUrl = commercialsList[index].thumbURL else { return nil }
        return URL(string: thumbUrl)
    }

    func shareUrlAtIndex(_ index: Int) -> URL? {
        guard let shareURL = commercialsList[index].shareURL else { return nil }
        return URL(string: shareURL)
    }
}


// MARK: - SocialShareViewDelegate - Share tracking

extension CommercialDisplayViewModel {
    var sharedTemplateId: String {
        return selectedCommercial?.templateId ?? ""
    }

    func shareStartedIn(_ shareType: ShareType) {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPlayer,
                                                          template: sharedTemplateId,
                                                          shareNetwork: shareType.trackingShareNetwork)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareFinishedIn(_ shareType: ShareType, withState state: SocialShareState) {
        guard state == .completed else { return }
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPlayer,
                                                             template: sharedTemplateId,
                                                             shareNetwork: shareType.trackingShareNetwork)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}
