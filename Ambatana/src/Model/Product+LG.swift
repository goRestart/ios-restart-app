//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension Product {
    func isMine(myUserId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && myUserId != nil else { return false }
        return ownerId == myUserId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return isMine(myUserId: myUserRepository.myUser?.objectId)
    }
}
