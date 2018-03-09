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
    
    static let headerStep: BlockingPostingHeaderStep = .addPrice
    
    private let listingRepository: ListingRepository
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    private let featureFlags: FeatureFlaggeable
    private let listing: Listing
    private let images: [UIImage]
    private let priceListing = Variable<ListingPrice>(Constants.defaultPrice)
    
    weak var navigator: BlockingPostingNavigator?
    
    private let disposeBag = DisposeBag()
    
    private var currencySymbol: String? {
        guard let countryCode = locationManager.currentLocation?.countryCode else { return nil }
        return currencyHelper.currencyWithCountryCode(countryCode).symbol
    }
    
    
    // MARK: - Lifecycle
    
    convenience init(listing: Listing, images: [UIImage]) {
        self.init(listingRepository: Core.listingRepository,
                  locationManager: Core.locationManager,
                  currencyHelper: Core.currencyHelper,
                  featureFlags: FeatureFlags.sharedInstance,
                  listing: listing,
                  images: images)
    }
    
    init(listingRepository: ListingRepository,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper,
         featureFlags: FeatureFlaggeable,
         listing: Listing,
         images: [UIImage]) {
        self.listingRepository = listingRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.featureFlags = featureFlags
        self.listing = listing
        self.images = images
        super.init()
    }

    
    // MARK: - PostingAddDetailPriceView
    
    func makePriceView() -> PostingAddDetailPriceView {
        let priceView = PostingAddDetailPriceView(currencySymbol: currencySymbol,
                                                  freeEnabled: featureFlags.freePostingModeAllowed, frame: CGRect.zero)
        priceView.priceListing.asObservable().bind(to: priceListing).disposed(by: disposeBag)
        return priceView
    }
    
    
    // MARK: - UI Actions
    
    func doneButtonAction() {
        guard let productParams = ProductEditionParams(listing: listing) else { return }
        var editParams = ListingEditionParams.product(productParams)
        if editParams.price != priceListing.value {
            editParams = editParams.updating(price: priceListing.value)
        }
        navigator?.openListingEditionLoading(listingParams: editParams, images: images)
    }
}
