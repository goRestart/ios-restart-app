//
//  BumpUpPayViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class BumpUpPayViewModel: BaseViewModel {

    var listing: Listing
    private let paymentItemId: String?
    private let storeProductId: String?
    private let typePage: EventParameterTypePage?

    var price: String {
        return purchaseableProduct.formattedCurrencyPrice
    }
    private let purchaseableProduct: PurchaseableProduct
    private let purchasesShopper: PurchasesShopper
    private let tracker: Tracker

    weak var navigator: BumpUpNavigator?


    // MARK: - Lifecycle

    convenience init(listing: Listing,
                     purchaseableProduct: PurchaseableProduct,
                     paymentItemId: String?,
                     storeProductId: String?,
                     typePage: EventParameterTypePage?) {
        let purchasesShopper = LGPurchasesShopper.sharedInstance
        self.init(listing: listing, purchaseableProduct: purchaseableProduct,
                  purchasesShopper: purchasesShopper, paymentItemId: paymentItemId,
                  storeProductId: storeProductId, typePage: typePage, tracker: TrackerProxy.sharedInstance)
    }

    init(listing: Listing,
         purchaseableProduct: PurchaseableProduct,
         purchasesShopper: PurchasesShopper,
         paymentItemId: String?,
         storeProductId: String?,
         typePage: EventParameterTypePage?,
         tracker: Tracker) {
        self.listing = listing
        self.purchaseableProduct = purchaseableProduct
        self.purchasesShopper = purchasesShopper
        self.tracker = tracker
        self.paymentItemId = paymentItemId
        self.storeProductId = storeProductId
        self.typePage = typePage
    }

    func viewDidAppear() {
        let trackerEvent = TrackerEvent.bumpBannerInfoShown(type: EventParameterBumpUpType(bumpType: .priced),
                                                            listingId: listing.objectId,
                                                            storeProductId: storeProductId,
                                                            typePage: typePage)
        tracker.trackEvent(trackerEvent)
    }

    
    // MARK: - Public methods

    func bumpUpPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.bumpUpProduct()
        })
    }

    func boostPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.boostProduct()
        })

    }

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }

    func timerReachedZero() {
        navigator?.bumpUpDidCancel()
    }


    // MARK: - Private methods

    private func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        guard let listingId = listing.objectId, let paymentItemId = paymentItemId else { return }
        purchasesShopper.requestPayment(forListingId: listingId,
                                        appstoreProduct: purchaseableProduct,
                                        paymentItemId: paymentItemId,
                                        isBoost: false)
    }

    private func boostProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Boost with purchase: \(purchaseableProduct)")
        guard let listingId = listing.objectId, let paymentItemId = paymentItemId else { return }
        purchasesShopper.requestPayment(forListingId: listingId,
                                        appstoreProduct: purchaseableProduct,
                                        paymentItemId: paymentItemId,
                                        isBoost: true)
    }
}
