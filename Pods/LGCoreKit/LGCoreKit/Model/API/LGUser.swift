//
//  LGUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public class LGUser: LGBaseModel, User {
    
    // User iVars
    public var username: String?
    public var password: String?
    public var email: String?
    public var publicUsername: String?
    
    public var avatar: File?
    
    public var gpsCoordinates: LGLocationCoordinates2D?
    public var postalAddress: PostalAddress
    
    public var processed: NSNumber?
    
    public var isDummy: Bool
    public var isAnonymous: Bool
    
    public var sessionToken: String?
    
    // Lifecycle
    
    public override init() {
        self.postalAddress = PostalAddress()
        self.processed = NSNumber(bool: true)
        self.isDummy = false
        self.isAnonymous = false
        super.init()
    }
}