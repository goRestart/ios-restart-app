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
    func productsRequest(request: PurchaseableProductsRequest, didReceiveResponse response: PurchaseableProductsResponse)
    func productsRequest(request: PurchaseableProductsRequest, didFailWithError error: NSError)
}

class AppstoreProductsRequest: NSObject, PurchaseableProductsRequest {

    private var request: SKProductsRequest

    weak var delegate: PurchaseableProductsRequestDelegate?

    init(ids: [String]) {
        request = SKProductsRequest(productIdentifiers: Set(ids))
        super.init()
        request.delegate = self
    }


    // MARK: - PurchaseableProductsRequest

    func start() {
        request.start()
    }

    func cancel() {
        request.cancel()
    }
}

extension AppstoreProductsRequest: SKProductsRequestDelegate {
    dynamic func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        self.request = request
        delegate?.productsRequest(self, didReceiveResponse: response)
    }

    dynamic func requestDidFinish(request: SKRequest) {

    }

    dynamic func request(request: SKRequest, didFailWithError error: NSError) {
        delegate?.productsRequest(self, didFailWithError: error)
    }
}
