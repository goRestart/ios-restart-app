//
//  FavProduct.swift
//  Ambatana
//
//  Created by AHL on 16/3/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Foundation

@objc protocol FavProduct {
    
    // Parse common
    var objectId: String! { get }
    var updatedAt: NSDate! { get }
    var createdAt: NSDate! { get }
    
    var product: Product? { get }
}

class PFFavProduct: PFObject, PFSubclassing, FavProduct {
    
    enum FieldKey: String {
        case Product = "product", User = "user", CreatedAt = "createdAt", UpdatedAt = "updatedAt"
    }
    
    // MARK: - Class
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    // MARK: - PFSubclassing
    
    class func parseClassName() -> String! {
        return "UserFavoriteProducts"
    }
    
    // MARK: - FavProduct
    
    var product: Product? {
        get {
            return self[FieldKey.Product.rawValue] as? Product
        }
    }
}