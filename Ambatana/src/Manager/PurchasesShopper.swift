//
//  PurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol PurchasesShopper: class {
    var delegate: PurchasesShopperDelegate? { get set }

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
     - parameter ids: array of ids of the appstore products
     */
    func productsRequestStartForListing(_ listingId: String, withIds ids: [String])
    
    func requestPayment(forListingId listingId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String)

    func isBumpUpPending(forListingId: String) -> Bool
    func requestFreeBumpUp(forListingId listingId: String, paymentItemId: String, shareNetwork: EventParameterShareNetwork)
    func restorePaidBumpUp(forListingId listingId: String)
}
