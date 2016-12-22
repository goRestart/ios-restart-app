//
//  MockPurchaseableProductsResponse.swift
//  LetGo
//
//  Created by Dídac on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import Foundation

class MockPurchaseableProductsResponse: PurchaseableProductsResponse {
    var purchaseableProducts: [PurchaseableProduct]
    var invalidProductIdentifiers: [String]

    convenience init() {
        self.init(purchaseableProducts: [], invalidProductIdentifiers: [])
    }

    init(purchaseableProducts: [PurchaseableProduct], invalidProductIdentifiers: [String]) {
        self.purchaseableProducts = purchaseableProducts
        self.invalidProductIdentifiers = invalidProductIdentifiers
    }
}
