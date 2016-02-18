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
    var isBlocking: Bool
}

extension LGUserUserRelation: Decodable {

    /**
     Expects a json in the form:

     {
     "is_blocked": false,
     "is_blocking": false
     }
     */
    static func decode(j: JSON) -> Decoded<LGUserUserRelation> {

        return curry(LGUserUserRelation.init)
            <^> LGArgo.mandatoryWithFallback(json: j, key: "is_blocked", fallback: false)
            <*> LGArgo.mandatoryWithFallback(json: j, key: "is_blocking", fallback: false)
    }
}
