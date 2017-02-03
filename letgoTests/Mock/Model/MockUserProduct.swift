//
//  MockUserProduct.swift
//  LetGo
//
//  Created by Juan Iglesias on 30/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import LGCoreKit

final class MockUserProduct: MockBaseModel, UserProduct {
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
    var banned: Bool?
    
    var sessionToken: String?
    
    var didLogInByFacebook: Bool
    
    
    var location: LGLocation?
    var status: UserStatus
    var name: String?
    
    var localeIdentifier: String?
    
    // Lifecycle
    
    override init() {
        self.postalAddress = PostalAddress.emptyAddress()
        self.processed = NSNumber(value: true as Bool)
        self.isDummy = false
        self.isAnonymous = false
        self.isScammer = NSNumber(value: false as Bool)
        self.didLogInByFacebook = false
        self.location = nil
        self.banned = nil
        self.status = .active
        super.init()
    }
    
    required init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, email: String?, location: LGLocation?, banned: Bool?) {
        self.isDummy = false
        self.isAnonymous = false
        self.didLogInByFacebook = false
        self.name = name
        self.avatar = avatar
        self.postalAddress = postalAddress
        self.email = email
        self.location = location
        self.status = .active
        self.banned = banned
        super.init()
        self.objectId = objectId
       
    }
}
