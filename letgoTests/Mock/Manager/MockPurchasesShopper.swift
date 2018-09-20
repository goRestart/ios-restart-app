//
//  MockPurchasesShopper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit

class MockPurchasesShopper: PurchasesShopper {
    weak var delegate: PurchasesShopperDelegate?
    weak var bumpInfoRequesterDelegate: BumpInfoRequesterDelegate?

    var isBumpUpPending: Bool = false
    var paymentSucceeds: Bool = false
    var pricedBumpSucceeds: Bool = false
    var restoreRetriesCount: Int = 0

    var currentBumpTypePage: EventParameterTypePage?
    var currentBumpIsBoost: Bool = false
    var currentAvailablePurchases: [FeaturePurchase] = []
    var storeToLetgoIdsMapper: [String:String] = [:]

    var timeOfRecentBump: TimeInterval? = nil
    var maxCountdown: TimeInterval? = nil
    var bumpUpType: BumpUpType? = nil

    func startObservingTransactions() {

    }

    func stopObservingTransactions() {

    }

    func restoreFailedBumps() {

    }

    func productsRequestStartForListingId(_ listingId: String,
                                          letgoItemId: String,
                                          providerItemId: String,
                                          maxCountdown: TimeInterval,
                                          timeSinceLastBump: TimeInterval,
                                          typePage: EventParameterTypePage?) {

        currentBumpTypePage = typePage
        storeToLetgoIdsMapper[providerItemId] = letgoItemId

        var purchaseableProduct = MockPurchaseableProduct.makeMock()
        purchaseableProduct.productIdentifier = providerItemId

        let featurePurchase = LGFeaturePurchase(purchaseType: (timeSinceLastBump > 0 ? .boost : .bump),
                                                featureDuration: maxCountdown,
                                                provider: .apple,
                                                letgoItemId: letgoItemId,
                                                providerItemId: providerItemId)

        let purchaseInfo = BumpUpProductData(purchaseableProduct: purchaseableProduct,
                                             letgoItemId: letgoItemId,
                                             storeProductId: providerItemId,
                                             featurePurchase: featurePurchase)

        bumpInfoRequesterDelegate?.shopperFinishedProductsRequestForListingId(listingId,
                                                                              withPurchases: [purchaseInfo],
                                                                              maxCountdown: maxCountdown,
                                                                              typePage: typePage)
    }

    func requestProviderForPurchases(purchases: [FeaturePurchase], listingId: String, typePage: EventParameterTypePage?) {

        currentBumpTypePage = typePage
        currentAvailablePurchases = purchases

        let storeProductIds = purchases.map { $0.providerItemId }

        purchases.forEach { [weak self] purchase in
            self?.storeToLetgoIdsMapper[purchase.providerItemId] = purchase.letgoItemId
        }
        let purchaseableProducts: [PurchaseableProduct] = storeProductIds.map { storeId in
            var product = MockPurchaseableProduct.makeMock()
            product.productIdentifier = storeId
            return product
        }

        let purchasesInfoArray: [BumpUpProductData] = purchaseableProducts.compactMap { [weak self] purchaseableProduct in
            return purchaseableProduct.toBumpUpProductData(storeToLetgoIdsMapper: self?.storeToLetgoIdsMapper,
                                                           currentAvailablePurchases: self?.currentAvailablePurchases)
        }

        bumpInfoRequesterDelegate?.shopperFinishedProductsRequestForListingId(listingId,
                                                                              withPurchases: purchasesInfoArray,
                                                                              maxCountdown: 0,
                                                                              typePage: typePage)
    }

    func requestPayment(forListingId listingId: String,
                        appstoreProduct: PurchaseableProduct,
                        letgoItemId: String,
                        maxCountdown: TimeInterval,
                        typePage: EventParameterTypePage?,
                        featurePurchaseType: FeaturePurchaseType) {
        delegate?.pricedBumpDidStartWith(storeProduct: appstoreProduct,
                                         typePage: currentBumpTypePage,
                                         featurePurchaseType: featurePurchaseType)

        performAfterDelayWithCompletion { [weak self] in
            guard let strongSelf = self else { return }
            if !strongSelf.paymentSucceeds {
                // payment fails
                strongSelf.delegate?.pricedBumpPaymentDidFail(withReason: nil, transactionStatus: .purchasingPurchased)
            } else if strongSelf.pricedBumpSucceeds {
                // payment works and bump works
                let paymentId = UUID().uuidString.lowercased()
                strongSelf.delegate?.pricedBumpDidSucceed(type: .priced,
                                                          restoreRetriesCount: strongSelf.restoreRetriesCount,
                                                          transactionStatus: .purchasingPurchased,
                                                          typePage: strongSelf.currentBumpTypePage,
                                                          isBoost: featurePurchaseType.isBoost,
                                                          paymentId: paymentId)
            } else {
                // payment works but bump fails
                strongSelf.delegate?.pricedBumpDidFail(type: .priced,
                                                       transactionStatus: .purchasingPurchased,
                                                       typePage: strongSelf.currentBumpTypePage,
                                                       isBoost: featurePurchaseType.isBoost)
            }
        }
    }

    func isBumpUpPending(forListingId: String) -> Bool {
        return isBumpUpPending
    }

    func timeSinceRecentBumpFor(listingId: String) -> RecentBumpInfo? {
        guard let timeOfRecentBump = timeOfRecentBump, let maxCountdown = maxCountdown,
            let bumpUpType = bumpUpType else { return nil }
        return RecentBumpInfo(timeDifference: timeOfRecentBump,
                              maxCountdown: maxCountdown,
                              bumpUpType: bumpUpType)
    }

    func restorePaidBumpUp(forListingId listingId: String) {
        delegate?.restoreBumpDidStart()
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
