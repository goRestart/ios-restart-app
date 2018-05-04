//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension Listing {
    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }

    func containsVideo() -> Bool {
        return media.contains(where: { $0.type == .video })
    }
}

extension Product {
    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }
}
