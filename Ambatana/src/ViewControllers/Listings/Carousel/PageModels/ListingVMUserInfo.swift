//
//  ListingVMUserInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 28/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct ListingVMUserInfo {
    let userId: String?
    let name: String
    let avatar: URL?
    let badge: UserReputationBadge

    private let ownerIsMyUser: Bool
    private let ownerUsername: String?
    private let ownerId: String?

    func avatarPlaceholder() -> UIImage? {
        if ownerIsMyUser {
            return LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor, name: ownerUsername)
        } else {
            return LetgoAvatar.avatarWithID(ownerId, name: ownerUsername)
        }
    }


    init(userListing: UserListing, myUser: MyUser?, sellerBadge: UserReputationBadge) {
        self.ownerId = userListing.objectId
        self.userId = ownerId

        if let productUserId = userListing.objectId, let myUser = myUser, let myUserId = myUser.objectId {
            ownerIsMyUser = (productUserId == myUserId )
        } else {
            ownerIsMyUser = false
        }

        let myUsername = myUser?.shortName
        let ownerUsername = userListing.shortName
        let myAvatarURL = myUser?.avatar?.fileURL
        let ownerAvatarURL = userListing.avatar?.fileURL
        self.avatar = ownerIsMyUser ? (myAvatarURL ?? ownerAvatarURL) : ownerAvatarURL
        self.name = ownerIsMyUser ? (myUsername ?? ownerUsername ?? "") : (ownerUsername ?? "")
        self.ownerUsername = ownerUsername
        self.badge = sellerBadge
    }

}
