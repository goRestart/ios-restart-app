//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

protocol PurchasesShopper: class {
    var delegate: PurchasesShopperDelegate? { get set }
    var bumpInfoRequesterDelegate: BumpInfoRequesterDelegate? { get set }

    /**
     Sets itself as the payment transactions observer
     */
    func startObservingTransactions()

    /**
     Removes itself as the payment transactions observer
     */
    func stopObservingTransactions()

    /**
     Restore the failed paid bumps (payment was made, but bump failed)
     */
    func restoreFailedBumps()
    
    /**
     Checks purchases available on appstore

     - parameter productId: ID of the listing for wich will request the appstore products
     - letgoItemId: internal id of the payment item
     - providerItemId: id of the appstore products
     */
    func productsRequestStartForListingId(_ listingId: String,
                                          letgoItemId: String,
                                          providerItemId: String,
                                          maxCountdown: TimeInterval,
                                          timeSinceLastBump: TimeInterval,
                                          typePage: EventParameterTypePage?)
    func requestProviderForPurchases(purchases: [FeaturePurchase],
                                     listingId: String,
                                     typePage: EventParameterTypePage?)

    func requestPayment(forListingId listingId: String,
                        appstoreProduct: PurchaseableProduct,
                        letgoItemId: String,
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?,
                        featurePurchaseType: FeaturePurchaseType)

    func isBumpUpPending(forListingId: String) -> Bool
    func timeSinceRecentBumpFor(listingId: String) -> RecentBumpInfo?
    func restorePaidBumpUp(forListingId listingId: String)
}
