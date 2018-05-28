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
    weak var bumpInfoRequesterDelegate: BumpInfoRequesterDelegate?

    var isBumpUpPending: Bool = false
    var paymentSucceeds: Bool = false
    var pricedBumpSucceeds: Bool = false
    var restoreRetriesCount: Int = 0

    var currentBumpTypePage: EventParameterTypePage?
    var currentBumpIsBoost: Bool = false

    var timeOfRecentBump: TimeInterval? = nil
    var maxCountdown: TimeInterval? = nil

    func startObservingTransactions() {

    }

    func stopObservingTransactions() {

    }

    func restoreFailedBumps() {

    }

    func productsRequestStartForListingId(_ listingId: String,
                                          letgoItemId: String,
                                          withIds ids: [String],
                                          maxCountdown: TimeInterval,
                                          typePage: EventParameterTypePage?) {

        currentBumpTypePage = typePage
        var purchaseableProducts: [PurchaseableProduct] = []

        ids.forEach { purchaseProductId in
            var purchaseableProduct = MockPurchaseableProduct.makeMock()
            purchaseableProduct.productIdentifier = purchaseProductId
            purchaseableProducts.append(purchaseableProduct)
        }
        
        bumpInfoRequesterDelegate?.shopperFinishedProductsRequestForListingId(listingId,
                                                                              withProducts: purchaseableProducts,
                                                                              letgoItemId: letgoItemId,
                                                                              storeProductId: ids.first,
                                                                              maxCountdown: maxCountdown,
                                                                              typePage: typePage)
    }
    
    
    func requestPayment(forListingId listingId: String,
                        appstoreProduct: PurchaseableProduct,
                        letgoItemId: String,
                        isBoost: Bool,
                        maxCountdown: TimeInterval) {
        delegate?.restoreBumpDidStart()
        
        performAfterDelayWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.paymentSucceeds {
                // payment fails
                strongSelf.delegate?.pricedBumpPaymentDidFail(withReason: nil, transactionStatus: .purchasingPurchased)
            } else if strongSelf.pricedBumpSucceeds {
                // payment works and bump works
                let paymentId = UUID().uuidString.lowercased()
                strongSelf.delegate?.pricedBumpDidSucceed(type: .priced, restoreRetriesCount: strongSelf.restoreRetriesCount,
                                                          transactionStatus: .purchasingPurchased, typePage: strongSelf.currentBumpTypePage,
                                                          isBoost: isBoost,
                                                          paymentId: paymentId)
            } else {
                // payment works but bump fails
                strongSelf.delegate?.pricedBumpDidFail(type: .priced, transactionStatus: .purchasingPurchased,
                                                       typePage: strongSelf.currentBumpTypePage, isBoost: isBoost)
            }
        }
    }

    func isBumpUpPending(forListingId: String) -> Bool {
        return isBumpUpPending
    }

    func timeSinceRecentBumpFor(listingId: String) -> (timeDifference: TimeInterval, maxCountdown: TimeInterval)? {
        guard let timeOfRecentBump = timeOfRecentBump, let maxCountdown = maxCountdown else { return nil }
        return (timeOfRecentBump, maxCountdown)
    }

    func requestFreeBumpUp(forListingId listingId: String, letgoItemId: String, shareNetwork: EventParameterShareNetwork) {

    }

    func restorePaidBumpUp(forListingId listingId: String) {
        delegate?.pricedBumpDidStart(typePage: currentBumpTypePage, isBoost: currentBumpIsBoost)
        if pricedBumpSucceeds {
            // payment works and bump works
            let paymentId = UUID().uuidString.lowercased()
            delegate?.pricedBumpDidSucceed(type: .restore, restoreRetriesCount: restoreRetriesCount,
                                           transactionStatus: .purchasingPurchased,
                                           typePage: currentBumpTypePage,
                                           isBoost: currentBumpIsBoost,
                                           paymentId: paymentId)
        } else {
            // payment works but bump fails
            delegate?.pricedBumpDidFail(type: .restore,
                                        transactionStatus: .purchasingPurchased,
                                        typePage: currentBumpTypePage,
                                        isBoost: currentBumpIsBoost)
        }
    }

    private func performAfterDelayWithCompletion(completion: (() -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(50)) {
            completion?()
        }
    }
}
