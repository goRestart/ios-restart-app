//
//  LGNotificationUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 22/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct LGNotificationUser: NotificationUser {
    public let id: String
    public let name: String?
    public let avatar: String?
}

extension LGNotificationUser: Decodable {
    private struct JSONKeys {
        static let userId = "user_id"
        static let userName = "username"
        static let userImage = "user_image"
    }

    public static func decode(_ j: JSON) -> Decoded<LGNotificationUser> {
        /*
         {
         "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
         "user_image": "Miss",
         "username": "Prof."
         }
         */
        let result1 = curry(LGNotificationUser.init)
        let result2 = result1 <^> j <| JSONKeys.userId
        let result3 = result2 <*> j <|? JSONKeys.userName
        let result  = result3 <*> j <|? JSONKeys.userImage
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotificationUser parse error: \(error)")
        }
        return result
    }
}
