//
//  BlockingPostingListingEditionViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 07/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class BlockingPostingListingEditionViewModel: BaseViewModel {
    
    enum ListingEditionState: Equatable {
        case updatingListing
        case success
        case error
        
        var message: String {
            switch self {
            case .updatingListing, .success:
                return ""
            case .error:
                return LGLocalizedString.productPostGenericError
            }
        }
        
        var isAnimated: Bool {
            return self == .updatingListing
        }
        
        var isError: Bool {
            return self == .error
        }
    }
    
    private let featureFlags: FeatureFlaggeable
    private let listingRepository: ListingRepository
    private let tracker: Tracker
    private let listingParams: ListingEditionParams
    private var listing: Listing
    private let imageSource: EventParameterPictureSource
    private let postingSource: PostingSource
    
    var state = Variable<ListingEditionState?>(nil)
    
    weak var navigator: BlockingPostingNavigator?
    
    
    // MARK: - Lifecycle

    convenience init(listingParams: ListingEditionParams,
                     listing: Listing,
                     imageSource: EventParameterPictureSource,
                     postingSource: PostingSource) {
        self.init(featureFlags: FeatureFlags.sharedInstance,
                  listingRepository: Core.listingRepository,
                  tracker: TrackerProxy.sharedInstance,
                  listingParams: listingParams,
                  listing: listing,
                  imageSource: imageSource,
                  postingSource: postingSource)
    }

    init(featureFlags: FeatureFlaggeable,
         listingRepository: ListingRepository,
         tracker: Tracker,
         listingParams: ListingEditionParams,
         listing: Listing,
         imageSource: EventParameterPictureSource,
         postingSource: PostingSource) {
        self.featureFlags = featureFlags
        self.listingRepository = listingRepository
        self.tracker = tracker
        self.listingParams = listingParams
        self.listing = listing
        self.imageSource = imageSource
        self.postingSource = postingSource
    }

    
    // MARK: - Requests
    
    func updateListing() {
        state.value = .updatingListing
        listingRepository.update(listingParams: listingParams) { [weak self] result in
            if let responseListing = result.value {
                self?.listing = responseListing
                self?.state.value = .success
            } else if let _ = result.error {
                self?.state.value = .error
            }
        }
    }
    
    
    // MARK: - Navigation
    
    func openListingPosted() {
        navigator?.openListingPosted(listing: listing)
    }
    
    func closeButtonAction() {
        trackPostSellComplete()
        navigator?.closePosting()
    }
    
    
    // MARK: - Tracking
    
    fileprivate func trackPostSellComplete() {
        let trackingInfo = PostListingTrackingInfo(buttonName: .close,
                                                   sellButtonPosition: postingSource.sellButtonPosition,
                                                   imageSource: imageSource,
                                                   price: String.fromPriceDouble(listing.price.value),
                                                   typePage: postingSource.typePage,
                                                   mostSearchedButton: postingSource.mostSearchedButton)
        
        let isFirmPrice = !listing.isNegotiable(freeModeAllowed: featureFlags.freePostingModeAllowed)
        let event = TrackerEvent.listingSellComplete(listing,
                                                     buttonName: trackingInfo.buttonName,
                                                     sellButtonPosition: trackingInfo.sellButtonPosition,
                                                     negotiable: trackingInfo.negotiablePrice,
                                                     pictureSource: trackingInfo.imageSource,
                                                     freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                     typePage: trackingInfo.typePage,
                                                     mostSearchedButton: trackingInfo.mostSearchedButton,
                                                     firmPrice: isFirmPrice)
        tracker.trackEvent(event)
    }
}
