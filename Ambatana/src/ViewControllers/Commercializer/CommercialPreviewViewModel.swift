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
    var socialMessage: SocialMessage? {
        guard let shareURL = commercializer.shareURL else { return nil }
        return SocialHelper.socialMessageCommercializer(shareURL, thumbUrl: thumbURL)
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
                                                         productId: productId, source: .CommercializerPreview) else { return }
        delegate?.vmShowCommercial(viewModel: viewModel)
    }
}

// MARK: - SocialShareViewDelegate

extension CommercialPreviewViewModel {

    func shareInEmail() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Email)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInEmailCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .Email)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInFacebook() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInFBCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .Facebook)
        TrackerProxy.sharedInstance.trackEvent(event)

    }

    func shareInFBMessenger() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInFBMessengerCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .FBMessenger)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInWhatsApp() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Whatsapp)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInTwitter() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Twitter)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInTwitterCompleted() {
        let event = TrackerEvent.commercializerShareComplete(productId, typePage: .CommercializerPreview,
                                                             template: templateId, shareNetwork: .Twitter)
        TrackerProxy.sharedInstance.trackEvent(event)
    }

    func shareInTelegram() {
        let event = TrackerEvent.commercializerShareStart(productId, typePage: .CommercializerPreview,
                                                          template: templateId, shareNetwork: .Telegram)
        TrackerProxy.sharedInstance.trackEvent(event)
    }
}