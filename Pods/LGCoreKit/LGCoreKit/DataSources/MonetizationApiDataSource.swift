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

    static let platformNameKey = "platformName"
    static let platformNameValue = "ios"

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


    // Private methods

    private static func decoderBumpeableProduct(object: Any) -> BumpeableProduct? {
        let bumpeableProduct: LGBumpeableProduct? = decode(object)
        return bumpeableProduct
    }
}
