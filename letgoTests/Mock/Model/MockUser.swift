//
//  MockUser.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

final class MockUser: MockBaseModel, MyUser {
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

    
    var location: LGLocation?
    var authProvider: AuthenticationProvider
    var name: String?
    
    // Lifecycle
    
    override init() {
        self.postalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.processed = NSNumber(bool: true)
        self.isDummy = false
        self.isAnonymous = false
        self.isScammer = NSNumber(bool: false)
        self.didLogInByFacebook = false
        self.location = nil
        self.authProvider = .Email
        super.init()
    }
    
    required init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, email: String?, location: LGLocation?, authProvider: AuthenticationProvider) {
        self.isDummy = false
        self.isAnonymous = false
        self.didLogInByFacebook = false
        self.name = name
        self.avatar = avatar
        self.postalAddress = postalAddress
        self.email = email
        self.location = location
        self.authProvider = authProvider
    }
}
