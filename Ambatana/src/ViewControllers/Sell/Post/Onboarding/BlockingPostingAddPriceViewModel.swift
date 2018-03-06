//
//  BlockingPostingAddPriceViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class BlockingPostingAddPriceViewModel: BaseViewModel {
    
    static let postingStepNumber = "3"
    let headerTitle: String
    
    private let listingRepository: ListingRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    private let featureFlags: FeatureFlaggeable
    private let listing: Listing
    
    weak var navigator: PostingHastenedCreateProductNavigator?
    
    private var currencySymbol: String? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode).symbol
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(listing: Listing,
                     postState: PostListingState) {
        self.init(listingRepository: Core.listingRepository,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper,
                  featureFlags: FeatureFlags.sharedInstance,
                  listing: listing,
                  postState: postState)
    }
    
    init(listingRepository: ListingRepository,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper,
         featureFlags: FeatureFlaggeable,
         listing: Listing,
         postState: PostListingState) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.featureFlags = featureFlags
        self.listing = listing
        self.headerTitle = LGLocalizedString.postAddPriceTitle
        super.init()
    }
    
    
    func nextButtonAction() {
        editListing()
    }
    
    func editListing() {
        guard let productParams = ProductEditionParams(listing: listing) else { return }
        let editParams = ListingEditionParams.product(productParams)
        self.listingRepository.update(listingParams: editParams) { result in
            if let responseListing = result.value {
                self.navigator?.openListingEditionLoading(listingParams: editParams)
            } else if let error = result.error {
                print("ko")
            }
        }
    }
    
    
    // MARK: - Navigation
    
    func openListingPosted() {
        //navigator?.openListingPosted(listing: nil, trackingInfo: nil)
    }
    
    func makePriceView(view: UIView) {
        let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                  freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
        priceView.setupContainerView(view: view)
    }
}
