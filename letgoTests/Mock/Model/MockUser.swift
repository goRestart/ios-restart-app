//
//  MockUser.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class MockUser: MockBaseModel, User {
    var username: String?
    var password: String?
    var email: String?
    var publicUsername: String?
    
    var avatar: File?
    
    var gpsCoordinates: LGLocationCoordinates2D?
    var postalAddress: PostalAddress
    
    var processed: NSNumber?
    
    var isDummy: Bool
    var isAnonymous: Bool
    
    var sessionToken: String?

    // Lifecycle
    
    override init() {
        self.postalAddress = PostalAddress()
        self.processed = NSNumber(bool: true)
        self.isDummy = false
        self.isAnonymous = false
        super.init()
    }
}
