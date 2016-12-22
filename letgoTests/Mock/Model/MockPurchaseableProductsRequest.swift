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
    var responseDelay: NSTimeInterval = 0.03

    func generatePurchaseableProductsRequest(ids: [String]) -> PurchaseableProductsRequest {
        return MockPurchaseableProductsRequest(responseDelay: responseDelay)
    }
}
class MockPurchaseableProductsRequest: PurchaseableProductsRequest {

    weak var delegate: PurchaseableProductsRequestDelegate?

    private var timer: NSTimer = NSTimer()
    private let responseDelay: NSTimeInterval

    init(responseDelay: NSTimeInterval) {
        self.responseDelay = responseDelay
    }

    func start() {
        timer = NSTimer.scheduledTimerWithTimeInterval(responseDelay, target: self, selector: #selector(launchResponse), userInfo: nil,
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
