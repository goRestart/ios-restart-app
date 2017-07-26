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
        let result1 = curry(LGAccount.init)
        let result2 = result1 <^> j <| "type"
        let result  = result2 <*> j <| "verified"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGAccount parse error: \(error)")
        }
        return result
    }
}
