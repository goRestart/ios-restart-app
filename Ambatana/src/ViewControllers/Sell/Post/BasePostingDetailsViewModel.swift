//
//  BaseRealEstateViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit


class BasePostingDetailsViewModel : BaseViewModel {
    
    var title: String {
        return step.title
    }
    let tracker: Tracker
    let step: PostingDetailStep
    
    weak var navigator: PostListingNavigator?
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep) {
        self.init(step: step, tracker: TrackerProxy.sharedInstance)
    }
    
    init(step: PostingDetailStep, tracker: Tracker) {
        self.step = step
        self.tracker = tracker
    }
    
    func closeButtonPressed() {
        navigator?.cancelPostListing()
    }
    
    func nextbuttonPressed() {
        navigator?.nextPostingDetailStep(step: .bedrooms)
    }
}
