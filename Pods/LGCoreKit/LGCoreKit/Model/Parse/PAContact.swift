//
//  PAContact.swift
//  LGCoreKit
//
//  Created by Dídac on 16/07/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import Parse


@objc public class PAContact: PFObject, PFSubclassing, Contact {

    // Constants & Enums
    
    enum FieldKey: String {
        case Email = "email" , Title = "title", Description = "description", Processed = "processed", User = "user"
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
    
    public static func parseClassName() -> String {
        return "Contacts"
    }

    
    // MARK: - Product
    
    public var email :String? {
        get {
            return self[FieldKey.Email.rawValue] as? String
        }
        set {
            self[FieldKey.Email.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var title :String? {
        get {
            return self[FieldKey.Title.rawValue] as? String
        }
        set {
            self[FieldKey.Title.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var message :String? {
        get {
            return self[FieldKey.Description.rawValue] as? String
        }
        set {
            self[FieldKey.Description.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var user :User? {
        get {
            return self[FieldKey.User.rawValue] as? User
        }
        set {
            self[FieldKey.User.rawValue] = newValue ?? NSNull()
        }
    }
    
    public var processed : NSNumber? {
        get {
            return self[FieldKey.Processed.rawValue] as? NSNumber
        }
        set {
            self[FieldKey.Processed.rawValue] = newValue ?? NSNull()
        }
    }

}
