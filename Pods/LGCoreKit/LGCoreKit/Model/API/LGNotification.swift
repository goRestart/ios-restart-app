//
//  LGNotification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGNotification: Notification {
    let objectId: String?
    let createdAt: NSDate
    let isRead: Bool
    let type: NotificationType

    init(objectId: String, createdAt: NSDate, isRead: Bool, type: NotificationType) {
        self.objectId = objectId
        self.createdAt = createdAt
        self.isRead = isRead
        self.type = type
    }
}

extension LGNotification : Decodable {

    /**
     Expects a json in the form:
     {
     "type": "Like/Follow/Sold",
     "uuid": "73aedba9-11db-3207-bb47-26812bfe8e71",
     "created_at": 1461569433,
     "is_read": false,

     ... type concrete data ...
     }
     */
    static func decode(j: JSON) -> Decoded<LGNotification> {
        let result = curry(LGNotification.init)
            <^> j <| "uuid"
            <*> j <| "created_at"
            <*> j <| "is_read"
            <*> NotificationType.decode(j)

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGNotification parse error: \(error)")
        }

        return result
    }
}


extension NotificationType: Decodable {
    public static func decode(j: JSON) -> Decoded<NotificationType> {
        guard let type: String = j.decode("type") else { return Decoded<NotificationType>.fromOptional(nil) }

        let result: Decoded<NotificationType>
        switch type {
        case "Like":
            /**
             {
             ...
             "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
             "product_image": "Ms.",
             "product_title": "Miss",
             "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
             "user_image": "Miss",
             "username": "Prof."
             }
             */
            result = curry(NotificationType.Like)
                <^> j <| "product_id"
                <*> j <|? "product_image"
                <*> j <|? "product_title"
                <*> j <| "user_id"
                <*> j <|? "user_image"
                <*> j <|? "username"
        case "Follow":
            /**
             {
             ...
             "user_follower_id": "3b93c7b4-ef5b-3b3c-a72c-5cc5539265ae",
             "user_follower_image": "Prof.",
             "user_follower_username": "Prof.",
             "user_follower_relationship": true
             }
             */
            result = curry(NotificationType.Follow)
                <^> j <| "user_follower_id"
                <*> j <|? "user_follower_image"
                <*> j <|? "user_follower_username"
                <*> j <| "user_follower_relationship"
        case "Sold":
            /**
             {
             ...
             "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
             "product_image": "Ms.",
             "product_title": "Miss",
             "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
             "user_image": "Miss",
             "username": "Prof."
             }
             */
            result = curry(NotificationType.Sold)
                <^> j <| "product_id"
                <*> j <|? "product_image"
                <*> j <|? "product_title"
                <*> j <| "user_id"
                <*> j <|? "user_image"
                <*> j <|? "username"
        default:
            return Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "NotificationType parse error: \(error)")
        }
        return result
    }
}
