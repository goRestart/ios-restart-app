//
//  LGAuthentication.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGAuthentication: Authentication {
    let id: String
    let token: String
}


// MARK: - Decodable

extension LGAuthentication: Decodable {
    /**
    Expects a json in the form:

    {
        "id": "string",
        "auth_token": "string"
    }
    */
    static func decode(_ j: JSON) -> Decoded<LGAuthentication> {
        let result1 = curry(LGAuthentication.init)
        let result2 = result1 <^> j <| "id"
        let result  = result2 <*> j <| "auth_token"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGAuthentication parse error: \(error)")
        }
        return result
    }
}
