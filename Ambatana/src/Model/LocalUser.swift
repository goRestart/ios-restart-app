//
//  LocalUser.swift
//  LetGo
//
//  Created by Eli Kohen on 02/11/2016.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct LocalUser: User, UserListing {

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

    let phone: String?
    let type: UserType
    let biography: String?
    let reputationPoints: Int

    init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, status: UserStatus,
         isDummy: Bool, banned: Bool?, phone: String?, type: UserType?, biography: String?, reputationPoints: Int) {
        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.postalAddress =  postalAddress
        self.accounts = []
        self.ratingAverage = nil
        self.ratingCount = 0
        self.status = status
        self.isDummy = isDummy
        self.banned = banned
        self.phone = phone
        self.type = type ?? .user
        self.biography = biography
        self.reputationPoints = reputationPoints
    }

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
        self.phone = nil
        self.type = .user
        self.biography = nil
        self.reputationPoints = 0
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
        self.phone = user.phone
        self.type = user.type
        self.biography = user.biography
        self.reputationPoints = user.reputationPoints
    }
    
    init(userListing: UserListing) {
        self.objectId = userListing.objectId
        self.name = userListing.name
        self.avatar = userListing.avatar
        self.postalAddress =  userListing.postalAddress
        self.accounts = []
        self.ratingAverage = nil
        self.ratingCount = 0
        self.status = userListing.status
        self.isDummy = false
        self.banned = userListing.banned
        self.phone = nil
        self.type = userListing.type
        self.biography = nil
        self.reputationPoints = 0
    }
}
