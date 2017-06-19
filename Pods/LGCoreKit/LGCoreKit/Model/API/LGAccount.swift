//
//  LGAccount.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGAccount: Account {
    let provider: AccountProvider
    let verified: Bool
}

extension LGAccount : Decodable {

    /**
     Expects a json in the form:
     {
        "type": "letgo",
        "verified": true
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGAccount> {
        return curry(LGAccount.init)
            <^> j <| "type"
            <*> j <| "verified"
    }
}
