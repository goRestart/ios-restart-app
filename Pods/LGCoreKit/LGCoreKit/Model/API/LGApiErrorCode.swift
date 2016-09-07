//
//  LGApiErrorCode.swift
//  LGCoreKit
//
//  Created by Dídac on 30/08/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGApiErrorCode: ApiErrorCode {
    let code: String
    let title: String
}

extension LGApiErrorCode : Decodable {

    /**
     Expects a json in the form:
        {
            "code": "1005",
            "title": "User already exists"
        }
     */
    static func decode(j: JSON) -> Decoded<LGApiErrorCode> {
        let result =  curry(LGApiErrorCode.init)
            <^> j <| "code"
            <*> j <| "title"
        if let error = result.error {
            print("LGApiErrorCode parse error: \(error)")
        }
        return result
    }
}
