//
//  Product+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension Product {
    var commercialsAllowed: Bool {
        guard let codeString = postalAddress.countryCode, let countryCode = CountryCode(rawValue: codeString)
            else { return false }
        switch countryCode {
        case .usa:
            return true
        default:
            return false
        }
    }

    func belongsTo(userId: String?) -> Bool {
        let ownerId = user.objectId
        guard user.objectId != nil && userId != nil else { return false }
        return ownerId == userId
    }

    func isMine(myUserRepository: MyUserRepository) -> Bool {
        return belongsTo(userId: myUserRepository.myUser?.objectId)
    }
}
