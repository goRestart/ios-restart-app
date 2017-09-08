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
    let avatarPlaceholder: UIImage?

    init(userListing: UserListing, myUser: MyUser?) {
        let ownerId = userListing.objectId
        self.userId = ownerId
        let ownerIsMyUser: Bool
        if let productUserId = userListing.objectId, let myUser = myUser, let myUserId = myUser.objectId {
            ownerIsMyUser = (productUserId == myUserId )
        } else {
            ownerIsMyUser = false
        }
        let myUsername = myUser?.shortName
        let ownerUsername = userListing.shortName
        self.name = ownerIsMyUser ? (myUsername ?? ownerUsername ?? "") : (ownerUsername ?? "")
        let myAvatarURL = myUser?.avatar?.fileURL
        let ownerAvatarURL = userListing.avatar?.fileURL
        self.avatar = ownerIsMyUser ? (myAvatarURL ?? ownerAvatarURL) : ownerAvatarURL

        if ownerIsMyUser {
            self.avatarPlaceholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor,
                                                                      name: ownerUsername)
        } else {
            self.avatarPlaceholder = LetgoAvatar.avatarWithID(ownerId, name: ownerUsername)
        }
    }
}
