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
    var hideProgressHeader:  Observable<Bool> {
        return currentStep.asObservable().map { [weak self] currentStep -> Bool in
            guard let isActive = self?.featureFlags.summaryAsFirstStep.isActive, let totalSteps = self?.totalSteps else {
                return false
            }
            return isActive || currentStep == 0 || currentStep > totalSteps
        }
    }
    var shouldModifyProgress: Bool = false
    var hasInitialCategory: Bool = false
    
    let featureFlags: FeatureFlags
    let disposeBag = DisposeBag()
    
    var actualStep: CGFloat {
        return currentStep.value
    }
    
    var totalSteps: CGFloat {
        return numberOfSteps.value
    }
   
    var postingFlowType: PostingFlowType {
        return featureFlags.postingFlowType
    }
    
    init(featureFlags: FeatureFlags) {
        self.featureFlags = featureFlags
        super.init()
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
