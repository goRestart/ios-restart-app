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
    var accounts: [Account]
    var status: UserStatus
    var name: String?
    
    var ratingAverage: Float?
    var ratingCount: Int

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
        self.accounts = [MockAccount(provider: .email, verified: true)]
        self.status = .active
        self.ratingCount = 0
        super.init()
    }
    
    required init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, email: String?, location: LGLocation?, accounts: [Account], ratingAccount: Int) {
        self.isDummy = false
        self.isAnonymous = false
        self.didLogInByFacebook = false
        self.name = name
        self.avatar = avatar
        self.postalAddress = postalAddress
        self.email = email
        self.location = location
        self.accounts = accounts
        self.status = .active
        self.ratingCount = ratingAccount
        super.init()
        self.objectId = objectId
    }
}
