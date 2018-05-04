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
    private let tracker: Tracker
    private let keyValueStorage: KeyValueStorage
    private let featureFlags: FeatureFlags
    private let listingParams: ListingCreationParams
    private let trackingInfo: PostListingTrackingInfo
    private var listingResult: ListingResult?
    
    weak var navigator: PostListingNavigator?
    private let disposeBag = DisposeBag()
    
    var finishRequest = Variable<Bool?>(false)
    
    // MARK: - LifeCycle
    
    convenience init(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo) {
        self.init(listingRepository: Core.listingRepository,
                  tracker: TrackerProxy.sharedInstance,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  listingParams: listingParams,
                  trackingInfo: trackingInfo)
    }
    
    init(listingRepository: ListingRepository,
         tracker: Tracker,
         keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlags,
         listingParams: ListingCreationParams,
         trackingInfo: PostListingTrackingInfo) {
        self.listingRepository = listingRepository
        self.tracker = tracker
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.listingParams = listingParams
        self.trackingInfo = trackingInfo
    }
    
    func createListing() {
        let shouldUseCarEndpoint = featureFlags.createUpdateIntoNewBackend.shouldUseCarEndpoint(with: listingParams)
        let createAction = listingRepository.createAction(shouldUseCarEndpoint)
        createAction(listingParams) { [weak self] result in
            if let listing = result.value, let trackingInfo = self?.trackingInfo {
                self?.trackPost(withListing: listing, trackingInfo: trackingInfo)
            } else if let error = result.error {
                self?.trackPostSellError(error: error)
            }
            self?.listingResult = result
            self?.finishRequest.value = true
        }
    }
    
    func nextStep() {
        guard let result = listingResult else {
            navigator?.cancelPostListing() // It should never happen
            return }
        navigator?.showConfirmation(listingResult: result, trackingInfo: trackingInfo, modalStyle: false)
    }
    
    private func trackPost(withListing listing: Listing, trackingInfo: PostListingTrackingInfo) {
        let event = TrackerEvent.listingSellComplete(listing,
                                                     buttonName: trackingInfo.buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource,
                                                     videoLength: trackingInfo.videoLength,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: trackingInfo.typePage,
                                                     mostSearchedButton: trackingInfo.mostSearchedButton,
                                                     machineLearningTrackingInfo: trackingInfo.machineLearningInfo)
        
        tracker.trackEvent(event)
        
        // Track product was sold in the first 24h (and not tracked before)
        if let firstOpenDate = keyValueStorage[.firstRunDate], Date().timeIntervalSince(firstOpenDate) <= 86400 &&
            !keyValueStorage.userTrackingProductSellComplete24hTracked {
            keyValueStorage.userTrackingProductSellComplete24hTracked = true
            
            let event = TrackerEvent.listingSellComplete24h(listing)
            tracker.trackEvent(event)
        }
    }
    
    private func trackPostSellError(error: RepositoryError) {
        let sellError: EventParameterPostListingError
        switch error {
        case .network:
            sellError = .network
        case .serverError, .notFound, .forbidden, .unauthorized, .tooManyRequests, .userNotVerified, .searchAlertError:
            sellError = .serverError(code: error.errorCode)
        case .internalError, .wsChatError:
            sellError = .internalError
        }
        let sellErrorDataEvent = TrackerEvent.listingSellErrorData(sellError)
        tracker.trackEvent(sellErrorDataEvent)
    }
}

