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

struct LGApiProductsErrorCode: ApiProductsErrorCode {
    let code: Int
    let message: String
}

extension LGApiProductsErrorCode : Decodable {

    /**
     Expects a json in the form:
        {
            "code": "1005",
            "message": "User already exists"
        }
     */
    static func decode(_ j: JSON) -> Decoded<LGApiProductsErrorCode> {
        let result =  curry(LGApiProductsErrorCode.init)
            <^> j <| "code"
            <*> j <| "message"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGApiProductsErrorCode parse error: \(error)")
        }
        return result
    }
}
