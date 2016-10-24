//
//  TourPostingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

class TourPostingViewModel: BaseViewModel {
    weak var navigator: TourPostingNavigator?

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
        titleText = LGLocalizedString.onboardingPostingTitleB
        subtitleText = LGLocalizedString.onboardingPostingSubtitleB
        okButtonText = LGLocalizedString.onboardingPostingButtonB
        super.init()
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

    func cameraButtonPressed() {
        navigator?.tourPostingPost(fromCamera: true)
    }

    func okButtonPressed() {
        navigator?.tourPostingPost(fromCamera: false)
    }

    func closeButtonPressed() {
        navigator?.tourPostingClose()
    }
}
