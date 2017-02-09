//
//  MockMyUser.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class MockMyUser: MyUser {
    // BaseModel
    var objectId: String?

    // User
    var name: String?
    var avatar: File?
    var postalAddress: PostalAddress = PostalAddress.emptyAddress()

    var accounts: [Account] = []
    var ratingAverage: Float?
    var ratingCount: Int = 0

    var status: UserStatus = .active

    var isDummy: Bool = true

    // MyUser
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?
    
    init() {
        objectId = String.random(20)
        name = String.random(10)
        avatar = nil
        isDummy = false
    }
    
    required init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, accounts: [Account], ratingAverage: Float?, ratingCount: Int, status: UserStatus, isDummy: Bool, email: String?, location: LGLocation?, localeIdentifier: String?) {
        
        self.objectId = objectId
        
        self.name = name
        self.avatar = avatar
        self.postalAddress = postalAddress
        
        self.accounts = accounts
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        
        self.status = status
        
        self.isDummy = isDummy

        self.email = email
        self.location = location
        self.localeIdentifier = localeIdentifier
    }

}
