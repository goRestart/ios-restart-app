//
//  LGProductsResponse.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public struct LGProductsResponse {
    
    public var products: NSArray
    public var totalProducts: Int
    public var offset: Int
    
    public var lastPage: Bool {
        get {
            return products.count + offset >= totalProducts
        }
    }
    
    // MARK: - Lifecycle
    
    public init() {
        products = []
        totalProducts = 0
        offset = 0
    }
}
