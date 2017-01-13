//
//  MockPurchaseableProductsRequest.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Foundation

class MockProductsRequestFactory: PurchaseableProductsRequestFactory {
    var responseDelay: TimeInterval = 0.03

    func generatePurchaseableProductsRequest(_ ids: [String]) -> PurchaseableProductsRequest {
        return MockPurchaseableProductsRequest(responseDelay: responseDelay)
    }
}
class MockPurchaseableProductsRequest: PurchaseableProductsRequest {

    weak var delegate: PurchaseableProductsRequestDelegate?

    fileprivate var timer: Timer = Timer()
    fileprivate let responseDelay: TimeInterval

    init(responseDelay: TimeInterval) {
        self.responseDelay = responseDelay
    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: responseDelay, target: self, selector: #selector(launchResponse), userInfo: nil,
                                                       repeats: false)
    }

    func cancel() {
        timer.invalidate()
    }

    dynamic func launchResponse() {
        let response = MockPurchaseableProductsResponse(purchaseableProducts: [MockPurchaseableProduct()], invalidProductIdentifiers: [])
        delegate?.productsRequest(self, didReceiveResponse: response)
    }
}
