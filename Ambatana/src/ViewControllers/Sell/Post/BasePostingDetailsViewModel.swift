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
    
    var makeContentView: UIView {
        var values: [String]
        switch step {
        case .bathrooms:
            values = NumberOfBathrooms.allValues.flatMap { $0.value }
        case .bedrooms:
            values = NumberOfBedrooms.allValues.flatMap { $0.value }
        case .offerType:
            values = RealEstateOfferType.allValues.flatMap { $0.value }
        case .propertyType:
            values = RealEstatePropertyType.allValues.flatMap { $0.value }
        case .price:
            return UIView()
        case .summary:
            return UIView()
        }
        return PostingAddDetailTableView(values: values)
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
