//
//  Product+ProductVM.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit


// MARK : - Product

extension Product {
    func viewModelStatus(_ featureFlags: FeatureFlaggeable) -> ProductViewModelStatus {
        switch status {
        case .pending:
            return isMine ? .pending : .notAvailable
        case .discarded, .deleted:
            return .notAvailable
        case .approved:
            if featureFlags.freePostingModeAllowed && price.free {
                return isMine ? .availableFree : .otherAvailableFree
            } else {
                return isMine ? .available : .otherAvailable
            }
        case .sold, .soldOld:
            if featureFlags.freePostingModeAllowed && price.free {
                return isMine ? .soldFree : .otherSoldFree
            } else {
                return isMine ? .sold : .otherSold
            }
        }
    }

    var isMine: Bool {
        let myUserId = Core.myUserRepository.myUser?.objectId
        let ownerId = user.objectId
        guard user.objectId != nil && myUserId != nil else { return false }
        return ownerId == myUserId
    }

    var isBumpeable: Bool {
        switch status {
        case .approved:
            return true
        case .pending, .discarded, .sold, .soldOld, .deleted:
            return false
        }
    }
}
