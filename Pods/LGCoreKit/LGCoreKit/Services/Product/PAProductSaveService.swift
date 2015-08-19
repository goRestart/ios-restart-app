//
//  PAProductSaveService.swift
//  LGCoreKit
//
//  Created by Dídac on 23/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse
import Result

final public class PAProductSaveService: ProductSaveService {

    // MARK: - Lifecycle
    
    public init() {
        
    }
    
    // MARK: - UserSaveService

    public func saveProduct(product: Product, forUser user: User, result: ProductSaveServiceResult?) {
        // Parse
        if let parseProduct = product as? PAProduct {
            saveParseProduct(parseProduct, forUser: user, result: result)
        }
        // Letgo
        else if let letgoProduct = product as? LGProduct {
            // Edit
            if let productId = letgoProduct.objectId {
                // Retrieve the product from parse
                var query = PFQuery(className: PAProduct.parseClassName())
                query.whereKey(PAProduct.FieldKey.ObjectId.rawValue, equalTo: productId)
                query.limit = 1
                query.includeKey(PAProduct.FieldKey.User.rawValue)
                query.findObjectsInBackgroundWithBlock { [weak self] (objects: [AnyObject]?, error: NSError?) in
                    
                    // Success
                    if let products = objects as? [PAProduct], let parseProduct = products.first {
                        // Update & save it
                        parseProduct.updateWithProduct(product)
                        self?.saveParseProduct(parseProduct, forUser: user, result: result)
                    }
                    // Error
                    else if let actualError = error {
                        switch(actualError.code) {
                        case PFErrorCode.ErrorConnectionFailed.rawValue:
                            result?(Result<Product, ProductSaveServiceError>.failure(.Network))
                        default:
                            result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
                        }
                    }
                    else {
                        result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
                    }
                }
            }
            // New
            else {
                // Create a parse product and save it
                var parseProduct = PAProduct.productFromProduct(letgoProduct)
                saveParseProduct(parseProduct, forUser: user, result: result)
            }
        }
        else {
            result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
        }
    }
    
    // MARK: - Private methods
    
    public func saveParseProduct(product: PAProduct, forUser user: User, result: ProductSaveServiceResult?) {
        if let userId = user.objectId {

            // Set the user, the ACL to global read access and write access for him/her, and mark the item as pending to review
            product.user = user
            product.acl = PFACL.globalReadAccessACLWithWriteAccessForUserIds([userId])
            product.processed = NSNumber(bool: false)
            product.status = .Pending
            
            // Save it
            product.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    result?(Result<Product, ProductSaveServiceError>.success(product))
                }
                else if let actualError = error {
                    switch(actualError.code) {
                    case PFErrorCode.ErrorConnectionFailed.rawValue:
                        result?(Result<Product, ProductSaveServiceError>.failure(.Network))
                    default:
                        result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
                    }
                }
                else {
                    result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
                }
            }
        }
        else {
            result?(Result<Product, ProductSaveServiceError>.failure(.Internal))
        }
    }
}