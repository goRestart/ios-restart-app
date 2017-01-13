//
//  PurchaseableProductsRequestFactory.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol PurchaseableProductsRequestFactory {
    func generatePurchaseableProductsRequest(_ ids: [String]) -> PurchaseableProductsRequest
}

class AppstoreProductsRequestFactory: PurchaseableProductsRequestFactory {
    func generatePurchaseableProductsRequest(_ ids: [String]) -> PurchaseableProductsRequest {
        return AppstoreProductsRequest(ids: ids)
    }
}
