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

    var accounts: [Account]?
    var ratingAverage: Float?
    var ratingCount: Int?

    var status: UserStatus = .active

    var isDummy: Bool = true

    // MyUser
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?
}
