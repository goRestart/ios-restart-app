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


    override init() {
        titleText = LGLocalizedString.onboardingPostingTitleB
        subtitleText = LGLocalizedString.onboardingPostingSubtitleB
        okButtonText = LGLocalizedString.onboardingPostingButtonB
        super.init()
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
