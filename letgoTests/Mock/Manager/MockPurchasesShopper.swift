//
//  MockPurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo

class MockPurchasesShopper: PurchasesShopper {
    weak var delegate: PurchasesShopperDelegate?

    func startObservingTransactions() {

    }

    func stopObservingTransactions() {

    }

    func productsRequestStartForProduct(_ productId: String, withIds ids: [String]) {

    }

    func requestPaymentForProduct(_ productId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {

    }

    func productIsPayedButNotBumped(_ productId: String) -> Bool {
        return Bool.random()
    }

    func requestFreeBumpUpForProduct(productId: String, withPaymentItemId paymentItemId: String, shareNetwork: EventParameterShareNetwork) {

    }

    func requestPricedBumpUpForProduct(_ productId: String) {

    }
}
