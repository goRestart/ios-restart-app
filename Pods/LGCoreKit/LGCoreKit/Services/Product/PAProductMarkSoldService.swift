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
        else if let letgoProduct = product as? LGProduct, let productId = letgoProduct.objectId {
            
            // After save: update the letgo product with the saved state
            let myResult = { (r: Result<Product, ProductMarkSoldServiceError>) -> Void in
                // Success
                if let savedProduct = r.value {
                    letgoProduct.updateWithProduct(savedProduct)
                }
                result?(r)
            }
            
            // Retrieve the product from parse
            var query = PFQuery(className: PAProduct.parseClassName())
            query.whereKey(PAProduct.FieldKey.ObjectId.rawValue, equalTo: productId)
            query.limit = 1
            query.includeKey(PAProduct.FieldKey.User.rawValue)
            query.findObjectsInBackgroundWithBlock { [weak self] (objects: [AnyObject]?, error: NSError?) in
                // Success
                if let products = objects as? [PAProduct], let parseProduct = products.first {
                    // Mark the parse product as sold
                    self?.markAsSoldParseProduct(parseProduct, result: myResult)
                }
                // Error
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        myResult(Result<Product, ProductMarkSoldServiceError>.failure(.Network))
                    default:
                        myResult(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
                    }
                }
                else {
                    myResult(Result<Product, ProductMarkSoldServiceError>.failure(.Internal))
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
