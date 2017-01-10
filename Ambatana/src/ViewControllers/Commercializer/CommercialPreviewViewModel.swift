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
    func vmShowCommercial(viewModel: CommercialDisplayViewModel)
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
                                                         source: .commercializerPreview,
                                                         isMyVideo: true) else { return }
        delegate?.vmShowCommercial(viewModel: viewModel)
    }
}
