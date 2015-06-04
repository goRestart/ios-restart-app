//
//  LGUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public class LGUser: User {
    
    // ProductUser iVars
    public var objectId: String!
    public var updatedAt: NSDate!
    public var createdAt: NSDate!
    
    public var username: String?
    public var password: String?
    public var email: String?
    public var publicUsername: String?
    
    public var avatarURL: NSURL?
    
    public var gpsCoordinates: LGLocationCoordinates2D?
    public var postalAddress: PostalAddress
    public var isDummy: NSNumber
    
    // Lifecycle
    
    public init() {
        self.postalAddress = PostalAddress()
        self.isDummy = false
    }
}