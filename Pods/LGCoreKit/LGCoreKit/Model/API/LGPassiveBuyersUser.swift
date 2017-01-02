//
//  LGPassiveBuyersUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

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
    static func decode(j: JSON) -> Decoded<LGPassiveBuyersUser> {
        let result = curry(LGPassiveBuyersUser.init)
            <^> j <|? "user_id"
            <*> j <|? "username"
            <*> j <|? "avatar"

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGPassiveBuyersUser parse error: \(error)")
        }
        return result
    }
}
