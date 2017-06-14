//
//  TourPostingViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 13/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol TourPostingViewModelDelegate: BaseViewModelDelegate { }

class TourPostingViewModel: BaseViewModel {
    weak var navigator: TourPostingNavigator?

    let titleText: String
    let subtitleText: String
    let okButtonText: String
    
    let featureFlags: FeatureFlaggeable

     weak var delegate: TourPostingViewModelDelegate?
    
    init(featureFlags: FeatureFlaggeable) {
        titleText = LGLocalizedString.onboardingPostingTitleB
        subtitleText = LGLocalizedString.onboardingPostingSubtitleB
        okButtonText = LGLocalizedString.onboardingPostingButtonB
        self.featureFlags = featureFlags
        super.init()
    }
    
    convenience override init() {
        self.init(featureFlags: FeatureFlags.sharedInstance)
    }

    func cameraButtonPressed() {
        navigator?.tourPostingPost(fromCamera: true)
    }

    func okButtonPressed() {
        navigator?.tourPostingPost(fromCamera: false)
    }

    func closeButtonPressed() {
        if featureFlags.newOnboardingPhase1 {
            let actionOk = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertYes),
                                    action: { [weak self] in self?.navigator?.tourPostingClose() })
            let actionCancel = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertNo),
                                        action: { [weak self] in self?.navigator?.tourPostingPost(fromCamera: false) })
            delegate?.vmShowAlert(LGLocalizedString.onboardingPostingAlertTitle,
                                  message: LGLocalizedString.onboardingPostingAlertSubtitle,
                                  actions: [actionCancel, actionOk])
        } else {
            navigator?.tourPostingClose()
        }
        
    }
}
