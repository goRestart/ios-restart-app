//
//  MonetizationApiDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Argo
import Result

class MonetizationApiDataSource : MonetizationDataSource {

    static let platformNameKey = "platform"
    static let platformNameValue = "ios"

    static let paymentIdKey = "id"
    static let itemIdKey = "item_id"
    static let productIdKey = "product_id"
    static let receiptDataKey = "receipt_data"
    static let priceAmountKey = "price_amount"
    static let priceCurrencyKey = "price_currency"

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // Public methods

    func retrieveBumpeableProductInfo(productId: String, completion: MonetizationDataSourceBumpeableProductCompletion?) {
        let request = MonetizationRouter.showBumpeable(productId: productId,
                                                       params: [MonetizationApiDataSource.platformNameKey:MonetizationApiDataSource.platformNameValue])
        apiClient.request(request, decoder: MonetizationApiDataSource.decoderBumpeableProduct, completion: completion)
    }

    func freeBump(forProduct productId: String, itemId: String, paymentId: String,
                  completion: MonetizationDataSourceBumpCompletion?) {
        let params: [String : Any] = [MonetizationApiDataSource.paymentIdKey: paymentId,
                                      MonetizationApiDataSource.itemIdKey: itemId,
                                      MonetizationApiDataSource.productIdKey: productId]
        let request = MonetizationRouter.freeBump(params: params)

        apiClient.request(request, completion: completion)
    }

    func pricedBump(forProduct productId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    paymentId: String, completion: MonetizationDataSourceBumpCompletion?) {
        let params: [String : Any] = [MonetizationApiDataSource.paymentIdKey: paymentId,
                                      MonetizationApiDataSource.receiptDataKey: receiptData,
                                      MonetizationApiDataSource.itemIdKey: itemId,
                                      MonetizationApiDataSource.productIdKey: productId,
                                      MonetizationApiDataSource.priceAmountKey: itemPrice,
                                      MonetizationApiDataSource.priceCurrencyKey: itemCurrency]
        let request = MonetizationRouter.pricedBump(params: params)

        apiClient.request(request, completion: completion)
    }

    // Private methods

    private static func decoderBumpeableProduct(object: Any) -> BumpeableProduct? {
        let bumpeableProduct: LGBumpeableProduct? = decode(object)
        return bumpeableProduct
    }
}
