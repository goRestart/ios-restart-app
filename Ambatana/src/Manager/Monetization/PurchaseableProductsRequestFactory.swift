//
//  PurchaseableProductsRequestFactory.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol PurchaseableProductsRequestFactory {
    func generatePurchaseableProductsRequest(ids: [String]) -> PurchaseableProductsRequest
}

class AppstoreProductsRequestFactory: PurchaseableProductsRequestFactory {
    func generatePurchaseableProductsRequest(ids: [String]) -> PurchaseableProductsRequest {
        return AppstoreProductsRequest(ids: ids)
    }
}
