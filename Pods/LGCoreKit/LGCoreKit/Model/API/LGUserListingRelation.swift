//
//  LGUserListingRelation.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGUserListingRelation: UserListingRelation {

    public var isFavorited: Bool
    public var isReported: Bool

}

extension LGUserListingRelation: Decodable {

    /**
    Expects a json in the form:

        {
          "is_reported": false,
          "is_favorited": false
        }
    */
    public static func decode(_ j: JSON) -> Decoded<LGUserListingRelation> {
        let result1 = curry(LGUserListingRelation.init)
        let result2 = result1 <^> LGArgo.mandatoryWithFallback(json: j, key: "is_favorited", fallback: false)
        let result  = result2 <*> LGArgo.mandatoryWithFallback(json: j, key: "is_reported", fallback: false)
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGUserListingRelation parse error: \(error)")
        }
        return result
    }
}
