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
        if let theProduct = product as? PAProduct, let userId = user.objectId {
            
            // Set the user, the ACL to global read access and write access for him/her, and mark the item as pending to review
            theProduct.user = user
            theProduct.acl = PFACL.globalReadAccessACLWithWriteAccessForUserIds([userId])
            theProduct.processed = NSNumber(bool: false)
            theProduct.status = .Pending
            
            // Save it
            theProduct.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    result?(Result<Product, ProductSaveServiceError>.success(theProduct))
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