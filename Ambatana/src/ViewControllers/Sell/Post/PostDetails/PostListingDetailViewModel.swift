//
//  PostListingDetailViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 17/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol PostListingDetailViewModelDelegate: class {
    func postListingDetailDone(_ viewModel: PostListingDetailViewModel)
}

class PostListingDetailViewModel: BaseViewModel {
    weak var delegate: PostListingDetailViewModelDelegate?

    // In variables
    let price = Variable<String>("")
    let title = Variable<String>("")
    let description = Variable<String>("")

    // In&Out variables
    let isFree = Variable<Bool>(false)
    
    // Out variables
    var listingPrice: ListingPrice {
        guard !isFree.value else { return .free }
        return price.value.toPriceDouble() > 0 ? .normal(price.value.toPriceDouble()) : .negotiable(price.value.toPriceDouble())
    }
    var listingTitle: String? {
        return title.value.isEmpty ? nil : title.value
    }
    var listingDescription: String? {
        return description.value.isEmpty ? nil : description.value
    }

    var featureFlags: FeatureFlaggeable
    let currencySymbol: String?

    var freeOptionAvailable: Bool {
        return featureFlags.freePostingModeAllowed
    }
    private let disposeBag = DisposeBag()

    override convenience  init() {
        var currencySymbol: String? = nil
        let featureFlags = FeatureFlags.sharedInstance
        if let countryCode = Core.locationManager.currentLocation?.countryCode {
            currencySymbol = Core.currencyHelper.currencyWithCountryCode(countryCode).symbol
        }
        self.init(currencySymbol: currencySymbol, featureFlags: featureFlags)
    }

    init(currencySymbol: String?, featureFlags: FeatureFlaggeable) {
        self.currencySymbol = currencySymbol
        self.featureFlags = featureFlags
        super.init()
    }

    func freeCellPressed() {
        isFree.value = !isFree.value
    }

    func doneButtonPressed() {
        delegate?.postListingDetailDone(self)
    }
}
