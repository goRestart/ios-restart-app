//
//  LocalUser.swift
//  LetGo
//
//  Created by Eli Kohen on 02/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct LocalUser: User {
    let objectId: String?
    let name: String?
    let avatar: File?
    let postalAddress: PostalAddress

    let accounts: [Account]? 
    let ratingAverage: Float?
    let ratingCount: Int?

    let status: UserStatus

    let isDummy: Bool

    init(chatInterlocutor: ChatInterlocutor) {
        self.objectId = chatInterlocutor.objectId
        self.name = chatInterlocutor.name
        self.avatar = chatInterlocutor.avatar
        self.postalAddress =  PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.accounts = nil
        self.ratingAverage = nil
        self.ratingCount = nil
        self.status = chatInterlocutor.status
        self.isDummy = false
    }
}
