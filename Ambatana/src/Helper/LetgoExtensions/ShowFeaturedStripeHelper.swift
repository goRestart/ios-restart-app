//
//  ShowFeaturedStripeHelper.swift
//  LetGo
//
//  Created by Dídac on 09/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

class ShowFeaturedStripeHelper {

    private let featureFlags: FeatureFlaggeable
    private let myUserRepository: MyUserRepository

    init(featureFlags: FeatureFlaggeable, myUserRepository: MyUserRepository) {
        self.featureFlags = featureFlags
        self.myUserRepository = myUserRepository
    }


    // MARK: Public methods

    func shouldShowFeaturedStripeFor(_ product: Product) -> Bool {
        guard let isFeatured = product.featured, isFeatured else { return false }
        // if the product is featured, the owner will always see the stripe, despite what the feature flag says
        return product.isMine(myUserRepository: myUserRepository) || featureFlags.pricedBumpUpEnabled
    }

    func shouldShowFeaturedStripeFor(listing: Listing) -> Bool {
        guard let isFeatured = listing.featured, isFeatured else { return false }
        // if the product is featured, the owner will always see the stripe, despite what the feature flag says
        return listing.isMine(myUserRepository: myUserRepository) || featureFlags.pricedBumpUpEnabled
    }
}
