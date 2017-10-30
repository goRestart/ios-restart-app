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
    
    var actualStep: CGFloat {
        return currentStep.value
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
    
    func widthToFill(totalWidth: CGFloat) -> CGFloat {
        guard numberOfSteps.value > 0 else { return 0 }
        return (totalWidth/numberOfSteps.value)*currentStep.value
    }
}
