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
    let bumpUpType: BumpUpType

    var price: String {
        return purchaseableProduct.formattedCurrencyPrice
    }
    var purchaseableProduct: PurchaseableProduct
    var purchasesShopper: PurchasesShopper

    weak var delegate: BumpUpPayViewModelDelegate?
    weak var navigator: BumpUpNavigator?


    // MARK: - Lifecycle

    convenience init(listing: Listing, purchaseableProduct: PurchaseableProduct, paymentItemId: String?, bumpUpType: BumpUpType) {
        let purchasesShopper = LGPurchasesShopper.sharedInstance
        self.init(listing: listing, purchaseableProduct: purchaseableProduct,
                  purchasesShopper: purchasesShopper, paymentItemId: paymentItemId, bumpUpType: bumpUpType)
    }

    init(listing: Listing, purchaseableProduct: PurchaseableProduct, purchasesShopper: PurchasesShopper,
         paymentItemId: String?, bumpUpType: BumpUpType) {
        self.listing = listing
        self.purchaseableProduct = purchaseableProduct
        self.purchasesShopper = purchasesShopper
        self.paymentItemId = paymentItemId
        self.bumpUpType = bumpUpType
    }


    // MARK: - Public methods

    func bumpUpPressed() {

        switch bumpUpType {
        case .priced:
            navigator?.bumpUpDidFinish(completion: { [weak self] in
                self?.bumpUpProduct()
            })
        case .hidden:
            // 🦄
        //        func showAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout = .horizontal, actions: [UIAction]?, dismissAction: (() -> ())? = nil) {
            break
        case .free, .restore:
            break
        }
    }

    func closeActionPressed() {
        navigator?.bumpUpDidCancel()
    }


    // MARK: - Private methods

    func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        guard let listingId = listing.objectId, let paymentItemId = paymentItemId else { return }
        purchasesShopper.requestPayment(forListingId: listingId, appstoreProduct: purchaseableProduct, paymentItemId: paymentItemId)
    }
}
