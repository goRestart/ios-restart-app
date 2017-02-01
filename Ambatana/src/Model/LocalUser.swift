//
//  LocalUser.swift
//  LetGo
//
//  Created by Eli Kohen on 02/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct LocalUser: User, UserProduct {
    let objectId: String?
    let name: String?
    let avatar: File?
    let postalAddress: PostalAddress

    let accounts: [Account]
    let ratingAverage: Float?
    let ratingCount: Int

    let status: UserStatus
    let banned: Bool?
    let isDummy: Bool

    init(chatInterlocutor: ChatInterlocutor) {
        self.objectId = chatInterlocutor.objectId
        self.name = chatInterlocutor.name
        self.avatar = chatInterlocutor.avatar
        self.postalAddress =  PostalAddress.emptyAddress()
        self.accounts = []
        self.ratingAverage = nil
        self.ratingCount = 0
        self.status = chatInterlocutor.status
        self.isDummy = false
        self.banned = chatInterlocutor.isBanned
    }
    
    init?(user: User?) {
        guard let user = user else { return nil }
        self.objectId = user.objectId
        self.name = user.name
        self.avatar = user.avatar
        self.postalAddress =  user.postalAddress
        self.accounts = user.accounts
        self.ratingAverage = user.ratingAverage
        self.ratingCount = user.ratingCount
        self.status = user.status
        self.isDummy = user.isDummy
        self.banned = nil
    }
    
    init(userProduct: UserProduct) {
        self.objectId = userProduct.objectId
        self.name = userProduct.name
        self.avatar = userProduct.avatar
        self.postalAddress =  userProduct.postalAddress
        self.accounts = []
        self.ratingAverage = nil
        self.ratingCount = 0
        self.status = userProduct.status
        self.isDummy = false
        self.banned = userProduct.banned
    }
}
