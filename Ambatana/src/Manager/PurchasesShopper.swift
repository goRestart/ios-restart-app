//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

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
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForListingId(_ listingId: String,
                                          letgoItemId: String,
                                          withIds ids: [String],
                                          maxCountdown: TimeInterval,
                                          typePage: EventParameterTypePage?)
    
    func requestPayment(forListingId listingId: String,
                        appstoreProduct: PurchaseableProduct,
                        letgoItemId: String,
                        isBoost: Bool,
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?)

    func isBumpUpPending(forListingId: String) -> Bool
    func timeSinceRecentBumpFor(listingId: String) -> (timeDifference: TimeInterval, maxCountdown: TimeInterval)?
    func requestFreeBumpUp(forListingId listingId: String, letgoItemId: String, shareNetwork: EventParameterShareNetwork)
    func restorePaidBumpUp(forListingId listingId: String)
}
