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

    static let platformNameKey = "platform"
    static let platformNameValue = "ios"
    static let minimumBumpPriceKey = "bucket"

    static let paymentIdKey = "id"
    static let itemIdKey = "item_id"
    static let listingIdKey = "product_id"
    static let receiptDataKey = "receipt_data"
    static let priceAmountKey = "price_amount"
    static let priceCurrencyKey = "price_currency"

    // Payment tracking info:
    static let analyticsContextKey = "analytics_context"
    static let amplitudeKey = "amplitude"
    static let amplitudeIdKey = "id"
    static let appsflyerKey = "appsflyer"
    static let appsflyerIdKey = "id"
    static let appsflyerIDFAKey = "idfa"
    static let appsflyerBundleIdKey = "bundle_id"


    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // Public methods

    func retrieveBumpeableListingInfo(listingId: String,
                                      withHigherMinimumPrice minPriceVersion: Int,
                                      completion: MonetizationDataSourceBumpeableListingCompletion?) {
        let request = MonetizationRouter.showBumpeable(listingId: listingId,
                                                       params: [MonetizationApiDataSource.platformNameKey:MonetizationApiDataSource.platformNameValue,
                                                                MonetizationApiDataSource.minimumBumpPriceKey:minPriceVersion])
        apiClient.request(request, decoder: MonetizationApiDataSource.decoderBumpeableListing, completion: completion)
    }

    func freeBump(forListingId listingId: String, itemId: String, paymentId: String,
                  completion: MonetizationDataSourceBumpCompletion?) {
        let params: [String : Any] = [MonetizationApiDataSource.paymentIdKey: paymentId,
                                      MonetizationApiDataSource.itemIdKey: itemId,
                                      MonetizationApiDataSource.listingIdKey: listingId]
        let request = MonetizationRouter.freeBump(params: params)

        apiClient.request(request, completion: completion)
    }

    func pricedBump(forListingId listingId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    paymentId: String, amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?,
                    completion: MonetizationDataSourceBumpCompletion?) {

        let analyticsParams: [String : Any] = buildAnalyticsParams(amplitudeId: amplitudeId, appsflyerId: appsflyerId, idfa: idfa, bundleId: bundleId)

        let params: [String : Any] = [MonetizationApiDataSource.paymentIdKey: paymentId,
                                      MonetizationApiDataSource.receiptDataKey: receiptData,
                                      MonetizationApiDataSource.itemIdKey: itemId,
                                      MonetizationApiDataSource.listingIdKey: listingId,
                                      MonetizationApiDataSource.priceAmountKey: itemPrice,
                                      MonetizationApiDataSource.priceCurrencyKey: itemCurrency,
                                      MonetizationApiDataSource.analyticsContextKey: analyticsParams]
        let request = MonetizationRouter.pricedBump(params: params)

        apiClient.request(request, completion: completion)
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

    private func buildAnalyticsParams(amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?) -> [String : Any] {

        // Analytics params are all or nothing for each tracker.
        // If one of the params for a tracking is missing, this particular
        // tracking (either amplitude or appsflyer) will be sent empty

        var amplitudeParams: [String : Any] = [:]
        if let amplitudeId = amplitudeId {
            amplitudeParams = [MonetizationApiDataSource.amplitudeIdKey: amplitudeId]
        }

        var appsflyerParams: [String : Any] = [:]
        if let appsflyerId = appsflyerId, let idfa = idfa, let bundleId = bundleId {
            appsflyerParams = [MonetizationApiDataSource.appsflyerIdKey: appsflyerId,
                               MonetizationApiDataSource.appsflyerIDFAKey: idfa,
                               MonetizationApiDataSource.appsflyerBundleIdKey: bundleId]
        }
        let analyticsParams: [String : Any] = [MonetizationApiDataSource.amplitudeKey: amplitudeParams,
                                               MonetizationApiDataSource.appsflyerKey: appsflyerParams]
        return analyticsParams
    }
}
