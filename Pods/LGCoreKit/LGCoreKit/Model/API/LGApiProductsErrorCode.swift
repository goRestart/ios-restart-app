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
            "code": 11001,
            "message": "Country code for product sender does not match"
        }
     */
    static func decode(_ j: JSON) -> Decoded<LGApiProductsErrorCode> {
        let result1 = curry(LGApiProductsErrorCode.init)
        let result2 = result1 <^> j <| "code"
        let result  = result2 <*> j <| "message"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGApiProductsErrorCode parse error: \(error)")
        }
        return result
    }
}
