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

    var product: Product
    var price: String {
        return purchaseableProduct.formattedCurrencyPrice
    }
    var purchaseableProduct: PurchaseableProduct
    var purchasesShopper: PurchasesShopper

    weak var delegate: BumpUpPayViewModelDelegate?
    weak var navigator: BumpUpNavigator?


    // MARK: - Lifecycle

    convenience init(product: Product, purchaseableProduct: PurchaseableProduct) {
        let purchasesShopper = LGPurchasesShopper.sharedInstance
        self.init(product: product, purchaseableProduct: purchaseableProduct,
                  purchasesShopper: purchasesShopper)
    }

    init(product: Product, purchaseableProduct: PurchaseableProduct, purchasesShopper: PurchasesShopper) {
        self.product = product
        self.purchaseableProduct = purchaseableProduct
        self.purchasesShopper = purchasesShopper
    }


    // MARK: - Public methods

    func bumpUpPressed() {
        bumpUpProduct()
        delegate?.vmDismiss(nil)
    }

    func closeActionPressed() {
        delegate?.vmDismiss(nil)
    }


    // MARK: - Private methods

    func bumpUpProduct() {
        logMessage(.info, type: [.monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        purchasesShopper.requestPaymentForProduct(purchaseableProduct.productIdentifier)
    }
}
