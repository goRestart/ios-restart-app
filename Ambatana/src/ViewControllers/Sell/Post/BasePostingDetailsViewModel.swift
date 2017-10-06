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
    
    var title: String
    let tracker: Tracker
    
    
    // MARK: - LifeCycle
    
    init(tracker: Tracker) {
        title = LGLocalizedString.categoriesTitle
        self.tracker = tracker
    }
    
    convenience override init() {
        self.init(tracker: TrackerProxy.sharedInstance)
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
    }
}
