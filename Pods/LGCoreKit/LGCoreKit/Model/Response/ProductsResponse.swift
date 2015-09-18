//
//  ProductsResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 01/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public protocol ProductsResponse {
    var products: NSArray { get }
    var totalProducts: NSNumber { get }
    var offset: NSNumber { get }
    var lastPage: NSNumber { get }
}