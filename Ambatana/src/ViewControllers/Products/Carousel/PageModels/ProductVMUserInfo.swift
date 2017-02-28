//
//  ProductVMUserInfo.swift
//  LetGo
//
//  Created by Eli Kohen on 28/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

struct ProductVMUserInfo {
    let userId: String?
    let name: String
    let avatar: URL?
    let avatarPlaceholder: UIImage?

    init(userProduct: UserProduct, myUser: MyUser?) {
        let ownerId = userProduct.objectId
        self.userId = ownerId
        let ownerIsMyUser: Bool
        if let productUserId = userProduct.objectId, let myUser = myUser, let myUserId = myUser.objectId {
            ownerIsMyUser = (productUserId == myUserId )
        } else {
            ownerIsMyUser = false
        }
        let myUsername = myUser?.shortName
        let ownerUsername = userProduct.shortName
        self.name = ownerIsMyUser ? (myUsername ?? ownerUsername ?? "") : (ownerUsername ?? "")
        let myAvatarURL = myUser?.avatar?.fileURL
        let ownerAvatarURL = userProduct.avatar?.fileURL
        self.avatar = ownerIsMyUser ? (myAvatarURL ?? ownerAvatarURL) : ownerAvatarURL

        if ownerIsMyUser {
            self.avatarPlaceholder = LetgoAvatar.avatarWithColor(UIColor.defaultAvatarColor,
                                                                      name: ownerUsername)
        } else {
            self.avatarPlaceholder = LetgoAvatar.avatarWithID(ownerId, name: ownerUsername)
        }
    }
}
