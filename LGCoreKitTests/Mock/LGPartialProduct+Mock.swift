//
//  LGPartialProduct+Mock.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit

extension LGPartialProduct {
    static func mock() -> LGPartialProduct {
        var partialProduct = LGPartialProduct(name: "name")
        partialProduct.objectId = "Google Logo"
        partialProduct.createdAt = NSDate()
        partialProduct.price = 50
        partialProduct.currency = .EUR
        partialProduct.distance = 10
        partialProduct.distanceType = .Mi
        partialProduct.categoryId = 1
        partialProduct.status = .Approved
        partialProduct.thumbnailURL = "https://www.google.com/images/srpr/logo11w.png"
        partialProduct.thumbnailSize = LGSize(width: 538, height: 190)
        return partialProduct
    }
    
    static func mocks(count: Int) -> [LGPartialProduct] {
        var partialProducts: [LGPartialProduct] = []
        for i in 0..<count {
            partialProducts.append(LGPartialProduct.mock())
        }
        
        return partialProducts
    }
}
