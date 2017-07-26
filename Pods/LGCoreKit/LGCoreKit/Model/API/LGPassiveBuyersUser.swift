//
//  LGPassiveBuyersUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGPassiveBuyersUser: PassiveBuyersUser {
    let objectId: String?
    let name: String?
    let avatar: File?

    init(objectId: String?, name: String?, avatar: String?) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
    }
}

extension LGPassiveBuyersUser: Decodable {
    /**
     {
        "user_id": "3234567892",
        "username": "username2",
        "avatar": "http:\/\/test\/avatar2.jpg"
     }
     */
    static func decode(_ j: JSON) -> Decoded<LGPassiveBuyersUser> {
        let result1 = curry(LGPassiveBuyersUser.init)
        let result2 = result1 <^> j <|? "user_id"
        let result3 = result2 <*> j <|? "username"
        let result  = result3 <*> j <|? "avatar"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGPassiveBuyersUser parse error: \(error)")
        }
        return result
    }
}
