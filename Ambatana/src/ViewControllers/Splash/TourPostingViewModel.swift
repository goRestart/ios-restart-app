//
//  TourPostingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol TourPostingViewModelDelegate: BaseViewModelDelegate {
    func vmClose()
}

class TourPostingViewModel: BaseViewModel {
    weak var delegate: TourPostingViewModelDelegate?

    let titleText: String
    let subtitleText: String
    let okButtonText: String
    var showIncentives: Bool {
        return incentiveImages.count > 0
    }

    private var incentiveImages: [UIImage] = []
    private var incentiveLabels: [String] = []
    private var incentiveValues: [String] = []

    override init() {
        switch FeatureFlags.incentivizePostingMode {
        case .Original, .VariantA:
            titleText = LGLocalizedString.onboardingPostingTitleA
            subtitleText = LGLocalizedString.onboardingPostingSubtitleA
            okButtonText = LGLocalizedString.onboardingPostingButtonA
        case .VariantB:
            titleText = LGLocalizedString.onboardingPostingTitleB
            subtitleText = LGLocalizedString.onboardingPostingSubtitleB
            okButtonText = LGLocalizedString.onboardingPostingButtonB
        case .VariantC:
            titleText = LGLocalizedString.onboardingPostingTitleC
            subtitleText = LGLocalizedString.onboardingPostingSubtitleC
            okButtonText = LGLocalizedString.onboardingPostingButtonC
        }
        super.init()

        setupIncentiveData()
    }

    func incentiveImageAt(index: Int) -> UIImage? {
        return incentiveImages[index]
    }

    func incentiveLabelAt(index: Int) -> String {
        return incentiveLabels[index]
    }

    func incentiveValueAt(index: Int) -> String {
        return incentiveValues[index]
    }

    func okButtonPressed() {
        delegate?.vmClose()
    }

    func closeButtonPressed() {
        delegate?.vmClose()
    }


    // MARK: - Private

    func setupIncentiveData() {
        guard FeatureFlags.incentivizePostingMode == .VariantC else { return }
        let itemPack = PostIncentiviserItem.incentiviserPack()
        guard itemPack.count == 3 else { return }

        for pack in itemPack {
            incentiveImages.append(pack.image ?? UIImage())
            incentiveLabels.append(pack.name)
            incentiveValues.append(pack.searchCount ?? "")
        }
    }
}

