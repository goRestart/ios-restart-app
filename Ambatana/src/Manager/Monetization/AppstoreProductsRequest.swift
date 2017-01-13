//
//  AppstoreProductsRequest.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import StoreKit

extension SKProduct: PurchaseableProduct {}

extension SKProductsResponse: PurchaseableProductsResponse {
    var purchaseableProducts: [PurchaseableProduct] {
        return products
    }
}

protocol PurchaseableProductsRequestDelegate: class {
    func productsRequest(_ request: PurchaseableProductsRequest, didReceiveResponse response: PurchaseableProductsResponse)
    func productsRequest(_ request: PurchaseableProductsRequest, didFailWithError error: Error)
}

class AppstoreProductsRequest: NSObject, PurchaseableProductsRequest {

    fileprivate var productsRequest: SKProductsRequest

    weak var delegate: PurchaseableProductsRequestDelegate?

    init(ids: [String]) {
        productsRequest = SKProductsRequest(productIdentifiers: Set(ids))
        super.init()
        productsRequest.delegate = self
    }


    // MARK: - PurchaseableProductsRequest

    func start() {
        productsRequest.start()
    }

    func cancel() {
        productsRequest.cancel()
    }
}

extension AppstoreProductsRequest: SKProductsRequestDelegate {
    dynamic func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.productsRequest = request
        delegate?.productsRequest(self, didReceiveResponse: response)
    }

    dynamic func requestDidFinish(_ request: SKRequest) {

    }

    dynamic func request(_ request: SKRequest, didFailWithError error: Error) {
        delegate?.productsRequest(self, didFailWithError: error)
    }
}
