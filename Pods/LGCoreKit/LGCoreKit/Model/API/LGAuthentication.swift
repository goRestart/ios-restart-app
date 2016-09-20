//
//  LGAuthentication.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

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
    static func decode(j: JSON) -> Decoded<LGAuthentication> {
        return curry(LGAuthentication.init)
            <^> j <| "id"
            <*> j <| "auth_token"
    }
}
