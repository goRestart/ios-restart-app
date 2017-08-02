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

    var titleText: String {
        switch featureFlags.copiesImprovementOnboarding {
        case .control, .baseline:
            return LGLocalizedString.onboardingPostingTitleB
        case .b:
            return LGLocalizedString.onboardingPostingImprovementBTitle
        case .c:
            return LGLocalizedString.onboardingPostingImprovementCTitle
        case .d:
            return LGLocalizedString.onboardingPostingImprovementDTitle
        case .e:
            return LGLocalizedString.onboardingPostingImprovementETitle
        case .f:
            return LGLocalizedString.onboardingPostingImprovementFTitle
        }
    }
    var subtitleText: String {
        switch featureFlags.copiesImprovementOnboarding {
        case .control, .baseline:
            return LGLocalizedString.onboardingPostingSubtitleB
        case .b, .c, .d, .e, .f:
            return ""
        }
    }
    
    var okButtonText: String  {
        switch featureFlags.copiesImprovementOnboarding {
        case .control, .baseline, .b, .d, .e, .f:
            return LGLocalizedString.onboardingPostingButtonB
        case  .c:
            return LGLocalizedString.onboardingPostingButtonB
        }
    }
    
    var hasSubtitle: Bool {
        switch featureFlags.copiesImprovementOnboarding {
        case .control, .baseline:
            return true
        case .b, .c, .d, .e, .f:
            return false
        }
    }
    
    let featureFlags: FeatureFlaggeable

     weak var delegate: TourPostingViewModelDelegate?
    
    init(featureFlags: FeatureFlaggeable) {
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
                                    action: { [weak self] in self?.navigator?.tourPostingPost(fromCamera: false) })
            let actionCancel = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertNo),
                                        action: { [weak self] in self?.navigator?.tourPostingClose() })
            delegate?.vmShowAlert(LGLocalizedString.onboardingPostingAlertTitle,
                                  message: LGLocalizedString.onboardingPostingAlertSubtitle,
                                  actions: [actionCancel, actionOk])
        } else {
            navigator?.tourPostingClose()
        }
        
    }
}
