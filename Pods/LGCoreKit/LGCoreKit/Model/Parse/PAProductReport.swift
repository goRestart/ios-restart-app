//
//  PAProductReport.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 18/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Parse

@objc public class PAProductReport: PFObject, PFSubclassing, ProductReport {
    
    // Constants & Enums
    
    internal enum FieldKey: String {
        case Product = "product_reported", UserReporter = "user_reporter", UserReported = "user_reported"
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
        return "UserReports"
    }
    
    // MARK: - ProductReport
    
    public var product: Product? {
        get {
            return self[FieldKey.Product.rawValue] as? PAProduct
        }
        set {
            self[FieldKey.Product.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var userReporter: User? {
        get {
            return self[FieldKey.UserReporter.rawValue] as? PFUser
        }
        set {
            self[FieldKey.UserReporter.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var userReported: User? {
        get {
            return self[FieldKey.UserReported.rawValue] as? PFUser
        }
        set {
            self[FieldKey.UserReported.rawValue] = newValue ?? NSNull()
        }
    }
}
