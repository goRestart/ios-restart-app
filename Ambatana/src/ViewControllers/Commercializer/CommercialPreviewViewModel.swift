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


    // MARK: - View lifecycle

    init(commercializer: Commercializer) {
        self.commercializer = commercializer
        super.init()
    }


    // MARK: - Public methods

    func closeButtonPressed() {
        delegate?.vmDismiss()
    }

    func playButtonPressed() {
        guard let viewModel = CommercialDisplayViewModel(commercializers: [commercializer]) else { return }
        delegate?.vmShowCommercial(viewModel: viewModel)
    }
}

// MARK: - SocialShareViewDelegate

extension CommercialPreviewViewModel {
    func shareInEmail() {

    }

    func shareInFacebook() {

    }

    func shareInFacebookFinished(state: SocialShareState) {

    }

    func shareInFBMessenger() {

    }

    func shareInFBMessengerFinished(state: SocialShareState) {

    }

    func shareInWhatsApp() {

    }
}