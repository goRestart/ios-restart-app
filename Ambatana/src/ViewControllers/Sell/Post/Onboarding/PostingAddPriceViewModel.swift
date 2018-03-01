//
//  PostingAddPriceViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

class PostingAddPriceViewModel: BaseViewModel {
    
    private let listingRepository: ListingRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    let featureFlags: FeatureFlaggeable
    private let listingCreationParams: ListingCreationParams
    
    weak var navigator: PostingAdvancedCreateProductNavigator?
    //private let disposeBag = DisposeBag()
    
    private var currencySymbol: String? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode).symbol
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(listingCreationParams: ListingCreationParams,
                     postState: PostListingState) {
        self.init(listingRepository: Core.listingRepository,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper,
                  featureFlags: FeatureFlags.sharedInstance,
                  listingCreationParams: listingCreationParams,
                  postState: postState)
    }
    
    init(listingRepository: ListingRepository,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper,
         featureFlags: FeatureFlaggeable,
         listingCreationParams: ListingCreationParams,
         postState: PostListingState) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.featureFlags = featureFlags
        self.listingCreationParams = listingCreationParams
        
        super.init()
    }
    
    
    // MARK: - Navigation
    
    func openListingPosted() {
        navigator?.openListingPosted(listingResult: nil, trackingInfo: nil)
    }
    
    func makePriceView(view: UIView) -> PostingViewConfigurable? {
        let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                  freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
        priceView.setupContainerView(view: view)
        
        return priceView
    }
}
