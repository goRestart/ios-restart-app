//
//  LGUserUserRelation.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 10/02/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGUserUserRelation: UserUserRelation {
    var isBlocked: Bool
    var isBlockedBy: Bool
}

extension LGUserUserRelation {

    /**
     Expects a json in the form:

     {
     "is_blocked": false,
     "is_blocking": false
     }
     */
    static func decode(_ j: JSON) -> LGUserUserRelation? {

        var userRelation = LGUserUserRelation(isBlocked: false, isBlockedBy: false)

        switch j {
        case let .array(responseArray):
            for item in responseArray {
                switch item {
                case .object:
                    guard let relation = LGUserUserRelation.decode(item) else { break }
                    userRelation.isBlocked = userRelation.isBlocked || relation.isBlocked
                    userRelation.isBlockedBy = userRelation.isBlockedBy || relation.isBlockedBy
                default:
                    break
                }
            }
        case let .object(element):
            guard let link_name = element["link_name"] else { break }
            switch link_name {
            case let .string(value):
                userRelation.isBlocked = value == "blocked"
                userRelation.isBlockedBy = value == "blocked_by"
            default:
                break
            }
        default:
            break
        }

        return userRelation
    }
}
