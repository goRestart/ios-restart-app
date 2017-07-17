//
//  LGApiErrorCode.swift
//  LGCoreKit
//
//  Created by Dídac on 30/08/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGApiUsersErrorCode: ApiUsersErrorCode {
    let code: String
    let title: String
}

extension LGApiUsersErrorCode : Decodable {

    /**
     Expects a json in the form:
        {
            "code": "1005",
            "title": "User already exists"
        }
     */
    static func decode(_ j: JSON) -> Decoded<LGApiUsersErrorCode> {
        let result =  curry(LGApiUsersErrorCode.init)
            <^> j <| "code"
            <*> j <| "title"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGApiUsersErrorCode parse error: \(error)")
        }
        return result
    }
}