//
//  SellNavigationViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 24/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift

class SellNavigationViewModel : BaseViewModel {
    
    let numberOfSteps = Variable<CGFloat>(0)
    let currentStep = Variable<CGFloat>(0)
    let categorySelected = Variable<PostCategory?>(nil)
    var shouldModifyProgress: Bool = false
    var hasInitialCategory: Bool = false
    
    let featureFlags: FeatureFlags
    
    var actualStep: CGFloat {
        return currentStep.value
    }
    
    var shouldShowPriceStep: Bool {
        return featureFlags.showPriceStepRealEstatePosting.isActive && hasInitialCategory
    }
    
    init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags
    }
    
    override convenience init() {
        self.init(featureFlags: FeatureFlags.sharedInstance)
    }
    
    
    // MARK: - Actions
    
    func navigationControllerPushed() {
        if shouldModifyProgress {
            currentStep.value = currentStep.value + 1
        }
    }
    
    func navigationControllerPop() {
        if shouldModifyProgress {
            currentStep.value = currentStep.value - 1
        }
    }    
}
