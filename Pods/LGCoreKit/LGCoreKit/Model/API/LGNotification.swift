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

    init(objectId: String?, createdAt: NSDate, isRead: Bool, type: NotificationType) {
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
         "data" : {... type concrete data ...}
     }
     */
    static func decode(j: JSON) -> Decoded<LGNotification> {
        let result = curry(LGNotification.init)
            <^> j <|? "uuid"
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

    struct JSONKeys {
        static let productId = ["data" , "product_id"]
        static let productTitle = ["data", "product_title"]
        static let productImage = ["data", "product_image"]
        static let userId = ["data" , "user_id"]
        static let userName = ["data" , "username"]
        static let userImage = ["data" , "user_image"]
        static let ratingValue = ["data" , "rating_value"]
        static let comments = ["data" , "comments"]
    }

    public static func decode(j: JSON) -> Decoded<NotificationType> {
        guard let type: String = j.decode("type") else { return Decoded<NotificationType>.fromOptional(nil) }

        let result: Decoded<NotificationType>
        switch type {
        case "like":
            /**
             "data" : {
                 "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
                 "product_image": "Ms.",
                 "product_title": "Miss",
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof."
             }
             */
            result = curry(NotificationType.Like)
                <^> j <| JSONKeys.productId
                <*> j <|? JSONKeys.productImage
                <*> j <|? JSONKeys.productTitle
                <*> j <| JSONKeys.userId
                <*> j <|? JSONKeys.userImage
                <*> j <|? JSONKeys.userName
        case "sold":
            /**
             "data" : {
                 "product_id": "a569527f-17e2-3d22-a513-2fc0c6477ac8",
                 "product_image": "Ms.",
                 "product_title": "Miss",
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof."
             }
             */
            result = curry(NotificationType.Sold)
                <^> j <| JSONKeys.productId
                <*> j <|? JSONKeys.productImage
                <*> j <|? JSONKeys.productTitle
                <*> j <| JSONKeys.userId
                <*> j <|? JSONKeys.userImage
                <*> j <|? JSONKeys.userName
        case "review":
            /**
             "data" : {
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof.",
                 "rating_value" : 4,
                 "comments": "Super!"
             }
             */
            result = curry(NotificationType.Rating)
                <^> j <| JSONKeys.userId
                <*> j <|? JSONKeys.userImage
                <*> j <|? JSONKeys.userName
                <*> j <| JSONKeys.ratingValue
                <*> j <|? JSONKeys.comments
        case "review_updated":
            /**
             "data" : {
                 "user_id": "3ba8869d-4d19-3b24-922f-5e2d61095bf3",
                 "user_image": "Miss",
                 "username": "Prof.",
                 "rating_value" : 4,
                 "comments": "Super!"
             }
             */
            result = curry(NotificationType.RatingUpdated)
                <^> j <| JSONKeys.userId
                <*> j <|? JSONKeys.userImage
                <*> j <|? JSONKeys.userName
                <*> j <| JSONKeys.ratingValue
                <*> j <|? JSONKeys.comments
        default:
            return Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "NotificationType parse error: \(error)")
        }
        return result
    }
}
