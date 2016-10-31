//
//  CommercialPreviewViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 04/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol CommercialPreviewViewModelDelegate: BaseViewModelDelegate {
    func vmDismiss()
    func vmShowCommercial(viewModel viewModel: CommercialDisplayViewModel)
}

class CommercialPreviewViewModel: BaseViewModel {

    weak var delegate: CommercialPreviewViewModelDelegate?

    var thumbURL: String? {
        return commercializer.thumbURL
    }
    var socialShareMessage: SocialMessage? {
        guard let shareURL = commercializer.shareURL else { return nil }
        return CommercializerSocialMessage(shareUrl: shareURL, thumbUrl: thumbURL)
    }

    private let commercializer: Commercializer
    private let productId: String
    private var templateId: String {
        return commercializer.templateId ?? ""
    }

    // MARK: - View lifecycle

    init(productId: String, commercializer: Commercializer) {
        self.productId = productId
        self.commercializer = commercializer
        super.init()
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        delegate?.vmDismiss()
    }

    func playButtonPressed() {
        guard let viewModel = CommercialDisplayViewModel(commercializers: [commercializer],
                                                         productId: productId,
                                                         source: .CommercializerPreview,
                                                         isMyVideo: true) else { return }
        delegate?.vmShowCommercial(viewModel: viewModel)
    }
}

// MARK: - SocialShareViewDelegate

extension CommercialPreviewViewModel {

    func didShareInEmail() {

        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Email)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInEmailCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .Email)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInFacebook() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInFBCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(event)

    }

    func didShareInFBMessenger() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInFBMessengerCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInWhatsApp() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Whatsapp)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInTwitter() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Twitter)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInTwitterCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .Twitter)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func didShareInTelegram() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Telegram)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func didShareInSMS() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .SMS)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func didShareInSMSCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .SMS)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
    
    func didShareInCopyLink() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .CopyLink)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

}
