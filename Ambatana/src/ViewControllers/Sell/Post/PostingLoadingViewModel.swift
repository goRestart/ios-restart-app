//
//  PostingLoadingViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

//
//  PostingDetailsViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 04/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

class PostingLoadingViewModel : BaseViewModel {
    
    var title: String {
        return "loading"
    }
    
    var buttonTitle: String {
        return "retry"
    }
    
    private let tracker: Tracker
    private let listingRepository: ListingRepository
    private let listingParams: ListingCreationParams
    private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    var fisnishRequest = Variable<Bool?>(false)
    var success: Bool = false
    
    // MARK: - LifeCycle
    
    convenience init(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo) {
        self.init(tracker: TrackerProxy.sharedInstance,
                  listingRepository: Core.listingRepository,
                  listingParams: listingParams,
                  trackingInfo: trackingInfo)
    }
    
    init(tracker: Tracker,
         listingRepository: ListingRepository,
        listingParams: ListingCreationParams,
        trackingInfo: PostListingTrackingInfo) {
        self.tracker = tracker
        self.listingRepository = listingRepository
        self.listingParams = listingParams
        self.trackingInfo = trackingInfo
    }
    
    func createListing() {
        listingRepository.create(listingParams: listingParams) { [weak self] (listingResult) in
            self?.fisnishRequest.value = true
            self?.listingResult = listingResult
            if let _ = listingResult.value {
               self?.success = true
            }
        }
    }
    
    func nextStep() {
        guard let result = listingResult else { return }
        navigator?.showConfirmation(listingResult: result, trackingInfo: trackingInfo, modalStyle: false)
    }
}

