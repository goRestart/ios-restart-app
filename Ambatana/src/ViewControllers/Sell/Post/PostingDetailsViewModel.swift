//
//  PostingDetailsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit


class PostingDetailsViewModel : BaseViewModel, PostingAddDetailTableViewDelegate {
    
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
        let view: PostingAddDetailTableView = PostingAddDetailTableView(values: values)
        view.delegate = self
        return view
    }
    
    private let tracker: Tracker
    private let step: PostingDetailStep
    private var postListingState: PostListingState
    
    weak var navigator: PostListingNavigator?
    
    // MARK: - LifeCycle
    
    convenience init(step: PostingDetailStep, postListingState: PostListingState) {
        self.init(step: step, postListingState: postListingState, tracker: TrackerProxy.sharedInstance)
    }
    
    init(step: PostingDetailStep, postListingState: PostListingState, tracker: Tracker) {
        self.step = step
        self.postListingState = postListingState
        self.tracker = tracker
    }
    
    func closeButtonPressed() {
        navigator?.cancelPostListing()
    }
    
    func nextbuttonPressed() {
        guard let next = step.nextStep else {
            //TODO: post in background item
            navigator?.cancelPostListing()
            return
        }
        navigator?.nextPostingDetailStep(step: next, postListingState: postListingState)
    }
    
    
    // MARK: - PostingAddDetailTableViewDelegate 
    
    func indexSelected(index: Int) {
        var numberOfBathrooms: NumberOfBathrooms? = nil
        var numberOfBedrooms: NumberOfBedrooms? = nil
        var realEstatePropertyType: RealEstatePropertyType? = nil
        var realEstateOfferType: RealEstateOfferType? = nil
        
        switch step {
        case .bathrooms:
            numberOfBathrooms = NumberOfBathrooms.allValues[index]
        case .bedrooms:
            numberOfBedrooms = NumberOfBedrooms.allValues[index]
        case .offerType:
            realEstateOfferType = RealEstateOfferType.allValues[index]
        case .propertyType:
            realEstatePropertyType = RealEstatePropertyType.allValues[index]
        case .price:
            return
        case .summary:
            return
        }

        var realEstateInfo = postListingState.realEstateInfo ?? RealEstateAttributes.emptyRealEstateAttributes()
        realEstateInfo = realEstateInfo.updating(propertyType: realEstatePropertyType,
                                                 offerType: realEstateOfferType,
                                                 bedrooms: numberOfBedrooms?.rawValue,
                                                 bathrooms: numberOfBathrooms?.rawValue)
        postListingState = postListingState.updating(realEstateInfo: realEstateInfo)
        delay(0.3) { [weak self] in
            self?.nextbuttonPressed()
        }
    }
}
