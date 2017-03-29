//
//  BumpUpPayViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


protocol BumpUpPayViewModelDelegate: BaseViewModelDelegate { }


class BumpUpPayViewModel: BaseViewModel {

    var listing: Listing
    let paymentItemId: String?

    var price: String {
        return purchaseableProduct.formattedCurrencyPrice
    }
    var purchaseableProduct: PurchaseableProduct
    var purchasesShopper: PurchasesShopper

    weak var delegate: BumpUpPayViewModelDelegate?
    weak var navigator: BumpUpNavigator?


    // MARK: - Lifecycle

    convenience init(listing: Listing, purchaseableProduct: PurchaseableProduct, paymentItemId: String?) {
        let purchasesShopper = LGPurchasesShopper.sharedInstance
        self.init(listing: listing, purchaseableProduct: purchaseableProduct,
                  purchasesShopper: purchasesShopper, paymentItemId: paymentItemId)
    }

    init(listing: Listing, purchaseableProduct: PurchaseableProduct, purchasesShopper: PurchasesShopper,
         paymentItemId: String?) {
        self.listing = listing
        self.purchaseableProduct = purchaseableProduct
        self.purchasesShopper = purchasesShopper
        self.paymentItemId = paymentItemId
    }


    // MARK: - Public methods

    func bumpUpPressed() {
        navigator?.bumpUpDidFinish(completion: { [weak self] in
            self?.bumpUpProduct()
        })
    }

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }


    // MARK: - Private methods

    func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        guard let productId = listing.objectId, let paymentItemId = paymentItemId else { return }
        purchasesShopper.requestPaymentForProduct(productId: productId, appstoreProduct: purchaseableProduct, paymentItemId: paymentItemId)
    }
}
