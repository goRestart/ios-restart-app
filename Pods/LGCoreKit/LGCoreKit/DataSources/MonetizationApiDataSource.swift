//
//  MonetizationApiDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

class MonetizationApiDataSource : MonetizationDataSource {

    private enum Keys {
        static let platformNameKey = "platform"
        static let platformNameValue = "ios"

        static let paymentIdKey = "id"
        static let itemIdKey = "item_id"
        static let listingIdKey = "product_id"
        static let receiptDataKey = "receipt_data"
        static let priceAmountKey = "price_amount"
        static let priceCurrencyKey = "price_currency"
        static let letgoItemIdKey = "letgo_item_id"

        static let availableProductsListingIdKey = "productIds"

        // Payment tracking info:
        static let analyticsContextKey = "analytics_context"
        static let amplitudeKey = "amplitude"
        static let amplitudeIdKey = "id"
        static let appsflyerKey = "appsflyer"
        static let appsflyerIdKey = "id"
        static let appsflyerIDFAKey = "idfa"
        static let appsflyerBundleIdKey = "bundle_id"
    }

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // Public methods

    func retrieveBumpeableListingInfo(listingId: String,
                                      completion: MonetizationDataSourceBumpeableListingCompletion?) {
        let request = MonetizationRouter.showBumpeable(listingId: listingId,
                                                       params: [Keys.platformNameKey:Keys.platformNameValue])
        apiClient.request(request, decoder: MonetizationApiDataSource.decoderBumpeableListing, completion: completion)
    }

    func freeBump(forListingId listingId: String, itemId: String, paymentId: String,
                  completion: MonetizationDataSourceBumpCompletion?) {
        let params: [String : Any] = [Keys.paymentIdKey: paymentId,
                                      Keys.itemIdKey: itemId,
                                      Keys.listingIdKey: listingId]
        let request = MonetizationRouter.freeBump(params: params)

        apiClient.request(request, completion: completion)
    }

    func pricedBump(forListingId listingId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    paymentId: String, letgoItemId: String, amplitudeId: String?, appsflyerId: String?, idfa: String?,
                    bundleId: String?, completion: MonetizationDataSourceBumpCompletion?) {

        let analyticsParams: [String : Any] = buildAnalyticsParams(amplitudeId: amplitudeId, appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId)

        let params: [String : Any] = [Keys.paymentIdKey: paymentId,
                                      Keys.receiptDataKey: receiptData,
                                      Keys.itemIdKey: itemId,
                                      Keys.listingIdKey: listingId,
                                      Keys.priceAmountKey: itemPrice,
                                      Keys.priceCurrencyKey: itemCurrency,
                                      Keys.analyticsContextKey: analyticsParams,
                                      Keys.letgoItemIdKey: letgoItemId]
        let request = MonetizationRouter.pricedBump(params: params)

        apiClient.request(request, completion: completion)
    }


    func retrieveAvailablePurchasesFor(listingIds: [String],
                                       completion: MonetizationDataSourceListingAvailablePurchasesCompletion?) {
        let params: [String:Any] = [Keys.platformNameKey:Keys.platformNameValue,
                                    Keys.availableProductsListingIdKey: listingIds]

        let request = MonetizationRouter.showAvailablePurchases(params: params)
        apiClient.request(request, decoder: MonetizationApiDataSource.decoderArrayAvailableFeaturePurchases, completion: completion)
    }


    // Private methods

    private static func decoderBumpeableListing(object: Any) -> BumpeableListing? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let bumpeableListing = try LGBumpeableListing.decode(jsonData: data)
            return bumpeableListing
        } catch {
            logAndReportParseError(object: object, entity: .bumpeableListing,
                                   comment: "could not parse LGBumpeableListing")
        }
        return nil
    }

    private static func decoderArrayAvailableFeaturePurchases(object: Any) -> [ListingAvailablePurchases]? {
        guard let availablePurchasesDict = object as? [String : Any] else { return nil }
        do {
            let listingsWithPurchases: [ListingAvailablePurchases] = try availablePurchasesDict
                .compactMap { (key, value) in
                    guard let purchasesData = try? JSONSerialization.data(withJSONObject: value,
                                                                          options: .prettyPrinted) else { return nil }
                    let purchases = try JSONDecoder().decode(LGAvailableFeaturePurchases.self, from: purchasesData)
                    return LGListingAvailablePurchases(listingId: key, purchases: purchases)
            }
            return listingsWithPurchases
        } catch {
            logAndReportParseError(object: object, entity: .listingAvailablePurchases,
                                   comment: "could not parse LGListingAvailablePurchases")
        }
        return nil
    }

    private func buildAnalyticsParams(amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?) -> [String : Any] {

        // Analytics params are all or nothing for each tracker.
        // If one of the params for a tracking is missing, this particular
        // tracking (either amplitude or appsflyer) will be sent empty

        var amplitudeParams: [String : Any] = [:]
        if let amplitudeId = amplitudeId {
            amplitudeParams = [Keys.amplitudeIdKey: amplitudeId]
        }

        var appsflyerParams: [String : Any] = [:]
        if let appsflyerId = appsflyerId, let idfa = idfa, let bundleId = bundleId {
            appsflyerParams = [Keys.appsflyerIdKey: appsflyerId,
                               Keys.appsflyerIDFAKey: idfa,
                               Keys.appsflyerBundleIdKey: bundleId]
        }
        let analyticsParams: [String : Any] = [Keys.amplitudeKey: amplitudeParams,
                                               Keys.appsflyerKey: appsflyerParams]
        return analyticsParams
    }
}
