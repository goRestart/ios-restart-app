//
//  ListingCreationViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 23/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import RxSwift
import LGCoreKit

class ListingCreationViewModel : BaseViewModel {
    
    private let listingRepository: ListingRepository
    private let listingParams: ListingCreationParams
    private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    var finishRequest = Variable<Bool?>(false)
    
    // MARK: - LifeCycle
    
    convenience init(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo) {
        self.init(listingRepository: Core.listingRepository,
                  listingParams: listingParams,
                  trackingInfo: trackingInfo)
    }
    
    init(listingRepository: ListingRepository,
        listingParams: ListingCreationParams,
        trackingInfo: PostListingTrackingInfo) {
        self.listingRepository = listingRepository
        self.listingParams = listingParams
        self.trackingInfo = trackingInfo
    }
    
    func createListing() {
        listingRepository.create(listingParams: listingParams) { [weak self] (listingResult) in
            self?.listingResult = listingResult
            self?.finishRequest.value = true
        }
    }
    
    func nextStep() {
        guard let result = listingResult else {
            navigator?.cancelPostListing() // It should never happen
            return }
        navigator?.showConfirmation(listingResult: result, trackingInfo: trackingInfo, modalStyle: false)
    }
}

