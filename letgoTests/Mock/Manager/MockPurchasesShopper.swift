//
//  MockPurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode

class MockPurchasesShopper: PurchasesShopper {
    weak var delegate: PurchasesShopperDelegate?
    var paymentSucceeds: Bool = false
    var pricedBumpSucceeds: Bool = false

    func startObservingTransactions() {

    }

    func stopObservingTransactions() {

    }

    func productsRequestStartForProduct(_ productId: String, withIds ids: [String]) {

    }

    func requestPaymentForProduct(productId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {
        delegate?.pricedBumpDidStart()
        if !paymentSucceeds {
            // payment fails
            delegate?.pricedBumpPaymentDidFail()
        } else if pricedBumpSucceeds {
            // payment works and bump works
            delegate?.pricedBumpDidSucceed()
        } else {
            // payment works but bump fails
            delegate?.pricedBumpDidFail()
        }
    }

    func isBumpUpPending(productId: String) -> Bool {
        return Bool.makeRandom()
    }

    func requestFreeBumpUpForProduct(productId: String, withPaymentItemId paymentItemId: String, shareNetwork: EventParameterShareNetwork) {

    }

    func requestPricedBumpUpForProduct(productId: String) {

    }
}
