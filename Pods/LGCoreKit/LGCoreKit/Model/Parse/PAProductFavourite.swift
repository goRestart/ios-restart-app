//
//  PAProductFavourite.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

@objc public class PAProductFavourite: PFObject, PFSubclassing, ProductFavourite {
    
    // Constants & Enums
    
    internal enum FieldKey: String {
        case Product = "product", User = "user"
        case ObjectId = "objectId"
    }
    
    // MARK: - Class
    
    override public class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    // MARK: - PFSubclassing
    
    public class func parseClassName() -> String {
        return "UserFavoriteProducts"
    }
    
    // MARK: - ProductFavourite
    
    public var product: Product? {
        get {
            return self[FieldKey.Product.rawValue] as? PAProduct
        }
        set {
            self[FieldKey.Product.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var user: User? {
        get {
            return self[FieldKey.User.rawValue] as? PFUser
        }
        set {
            self[FieldKey.User.rawValue] = newValue ?? NSNull()
        }
    }
}
