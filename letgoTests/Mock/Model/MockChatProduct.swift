//
//  MockChatProduct.swift
//  LetGo
//
//  Created by Albert Hernández López on 18/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct MockChatProduct: ChatProduct {
    var objectId: String?
    var name: String?
    var status: ProductStatus
    var image: File?
    var price: ProductPrice
    var currency: Currency

    // MARK: - Lifecycle

    init() {
        self.status = .Pending
        self.price = .Negotiable(100)
        self.currency = Currency(code: "EUR", symbol: "€")
    }
}
