//
//  PAProductMarkSoldService.swift
//  LGCoreKit
//
//  Created by AHL on 29/7/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductMarkSoldService: ProductMarkSoldService {
    
    // MARK: - Lifecycle
    
    public init() {
    }
    
    // MARK: - ProductMarkSoldService
    
    public func markAsSoldProduct(product: Product, result: ProductMarkSoldServiceResult?) {
        
        // Parse
        if let parseProduct = product as? PAProduct {
            markAsSoldParseProduct(parseProduct, result: result)
        }
        // API
        else if let actualProduct = product as? LGProduct, let productId = actualProduct.objectId {
            
            // Retrieve the product from parse
            var query = PFQuery(className: PAProduct.parseClassName())
            query.whereKey(PAProduct.FieldKey.ObjectId.rawValue, equalTo: productId)
            query.limit = 1
            query.includeKey(PAProduct.FieldKey.User.rawValue)
            query.findObjectsInBackgroundWithBlock { [weak self] (objects: [AnyObject]?, error: NSError?) in
                // Success
                if let products = objects as? [PAProduct] {
                    // If empty, then it's an error
                    if products.isEmpty {
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                    }
                    // Otherwise, mark the parse product as sold
                    else {
                        let parseProduct = products.first!
                        self?.markAsSoldParseProduct(parseProduct, result: result)
                    }
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Network))
                    default:
                        result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                }
            }
        }
        // Other source is an error
        else {
            result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
        }
    }
    
    // MARK: - Private methods
    
    private func markAsSoldParseProduct(product: PAProduct, result: ProductMarkSoldServiceResult?) {
        product.status = .Sold
        product.processed = NSNumber(bool: false)
        product.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            
            // Success
            if success {
                result?(Result<Product, ProductMarkSoldServiceError>.success(product))
            }
            // Error
            else if let actualError = error {
                switch(actualError.code) {
                case PFErrorCode.ErrorConnectionFailed.rawValue:
                    result?(Result<Product, ProductMarkSoldServiceError>.failure(.Network))
                default:
                    result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                }
            }
            else {
                result?(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
            }
        }
    }
}
