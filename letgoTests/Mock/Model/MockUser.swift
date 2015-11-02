//
//  MockUser.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class MockUser: MockBaseModel, MyUser {
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
    var isScammer: NSNumber?
    
    var sessionToken: String?
    
    var didLogInByFacebook: Bool

    // Lifecycle
    
    override init() {
        self.postalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.processed = NSNumber(bool: true)
        self.isDummy = false
        self.isAnonymous = false
        self.isScammer = NSNumber(bool: false)
        self.didLogInByFacebook = false
        super.init()
    }
}
