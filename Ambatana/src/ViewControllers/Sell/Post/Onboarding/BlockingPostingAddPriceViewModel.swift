//
//  BlockingPostingAddPriceViewModel.swift
//  LetGo
//
//  Created by Raúl de Oñate Blanco on 19/02/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class BlockingPostingAddPriceViewModel: BaseViewModel {
    
    static let postingStepNumber = "3"
    let headerTitle: String
    
    fileprivate let listingRepository: ListingRepository
    fileprivate let locationManager: LocationManager
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let listing: Listing
    fileprivate let priceListing = Variable<ListingPrice>(Constants.defaultPrice)
    
    weak var navigator: BlockingPostingNavigator?
    
    fileprivate let disposeBag = DisposeBag()
    
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

    
    // MARK: - PostingAddDetailPriceView
    
    func makePriceView(view: UIView) {
        let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                  freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
        priceView.setupContainerView(view: view)
        priceView.priceListing.asObservable().bind(to: priceListing).disposed(by: disposeBag)
    }
    
    
    // MARK: - UI Actions
    
    func doneButtonAction() {
        guard let productParams = ProductEditionParams(listing: listing) else { return }
        var editParams = ListingEditionParams.product(productParams)
        if editParams.price != priceListing.value {
            editParams = editParams.updating(price: priceListing.value)
        }
        navigator?.openListingEditionLoading(listingParams: editParams)
    }
}
