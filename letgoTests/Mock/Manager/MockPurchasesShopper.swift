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

    var isBumpUpPending: Bool = false
    var paymentSucceeds: Bool = false
    var pricedBumpSucceeds: Bool = false

    func startObservingTransactions() {

    }

    func stopObservingTransactions() {

    }

    func productsRequestStartForProduct(_ productId: String, withIds ids: [String]) {

        var purchaseableProducts: [PurchaseableProduct] = []

        ids.forEach { purchaseProductId in
            var purchaseableProduct = MockPurchaseableProduct.makeMock()
            purchaseableProduct.productIdentifier = purchaseProductId
            purchaseableProducts.append(purchaseableProduct)
        }

        delegate?.shopperFinishedProductsRequestForProductId(productId, withProducts: purchaseableProducts)
    }

    func requestPaymentForProduct(productId: String, appstoreProduct: PurchaseableProduct, paymentItemId: String) {
        delegate?.pricedBumpDidStart()

        performAfterDelayWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.paymentSucceeds {
                // payment fails
                strongSelf.delegate?.pricedBumpPaymentDidFail()
            } else if strongSelf.pricedBumpSucceeds {
                // payment works and bump works
                strongSelf.delegate?.pricedBumpDidSucceed()
            } else {
                // payment works but bump fails
                strongSelf.delegate?.pricedBumpDidFail()
            }
        }
    }

    func isBumpUpPending(productId: String) -> Bool {
        return isBumpUpPending
    }

    func requestFreeBumpUpForProduct(productId: String, withPaymentItemId paymentItemId: String, shareNetwork: EventParameterShareNetwork) {

    }

    func requestPricedBumpUpForProduct(productId: String) {
        delegate?.pricedBumpDidStart()
        if pricedBumpSucceeds {
            // payment works and bump works
            delegate?.pricedBumpDidSucceed()
        } else {
            // payment works but bump fails
            delegate?.pricedBumpDidFail()
        }
    }

    private func performAfterDelayWithCompletion(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion?()
        }
    }
}
