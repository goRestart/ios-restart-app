//
//  BumpUpPayViewModel.swift
//  LetGo
//
//  Created by Dídac on 19/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit


protocol BumpUpPayViewModelDelegate: BaseViewModelDelegate {
    func viewControllerShouldClose()
}


class BumpUpPayViewModel: BaseViewModel {

    var product: Product
    var price: String
    var bumpsLeft: Int
    var purchaseableProduct: PurchaseableProduct
    var purchasesShopper: PurchasesShopper

    weak var delegate: BumpUpPayViewModelDelegate?


    // MARK: - Lifecycle

    convenience init(product: Product, price: String, bumpsLeft: Int, purchaseableProduct: PurchaseableProduct) {
        let purchasesShopper = PurchasesShopper.sharedInstance
        self.init(product: product, price: price, bumpsLeft: bumpsLeft, purchaseableProduct: purchaseableProduct,
                  purchasesShopper: purchasesShopper)
    }

    init(product: Product, price: String, bumpsLeft: Int, purchaseableProduct: PurchaseableProduct, purchasesShopper: PurchasesShopper) {
        self.price = price
        self.product = product
        self.bumpsLeft = bumpsLeft
        self.purchaseableProduct = purchaseableProduct
        self.purchasesShopper = purchasesShopper
    }


    // MARK: - Public methods

    func bumpUpPressed() {
        bumpUpProduct()
        delegate?.viewControllerShouldClose()
    }

    func closeActionPressed() {
        delegate?.viewControllerShouldClose()
    }


    // MARK: - Private methods

    func bumpUpProduct() {
        logMessage(.Info, type: [.Monetization], message: "TRY TO Bump with purchase: \(purchaseableProduct)")
        purchasesShopper.requestPaymentForProduct(purchaseableProduct.productIdentifier)
    }
}
