//
//  LGNotification.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 25/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGNotification: NotificationModel {
    let objectId: String?
    let createdAt: Date
    let isRead: Bool
    let type: NotificationType
    let campaignType: String?

    init(objectId: String?, createdAt: Date, isRead: Bool, type: NotificationType, campaignType: String?) {
        self.objectId = objectId
        self.createdAt = createdAt
        self.isRead = isRead
        self.type = type
        self.campaignType = campaignType
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
    static func decode(_ j: JSON) -> Decoded<LGNotification> {
        let result1 = curry(LGNotification.init)
        let result2 = result1 <^> j <|? "uuid"
        let result3 = result2 <*> j <| "created_at"
        let result4 = result3 <*> j <| "is_read"
        let result5 = result4 <*> NotificationType.decode(j)
        let result  = result5 <*> j <|? "campaign_type"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotification parse error: \(error)")
        }
        return result
    }
}


extension NotificationType: Decodable {
    private struct JSONKeys {
        static let buyers = "buyers"
        static let ratingValue = "rating_value"
        static let comments = "comments"
    }

    public static func decode(_ j: JSON) -> Decoded<NotificationType> {
        guard let type: String = j.decode("type") else { return Decoded<NotificationType>.fromOptional(nil) }
        guard let data: JSON = j.decode("data") else { return Decoded<NotificationType>.fromOptional(nil) }

        let result: Decoded<NotificationType>
        switch type {
        case "modular":
            let result1 = curry(NotificationType.makeModular)
            result      = result1 <^> LGNotificationModular.decode(data)
        default:
            return Decoded<NotificationType>.fromOptional(nil)
        }

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "NotificationType parse error: \(error)")
        }
        return result
    }
}

fileprivate extension NotificationType {
    static func makeModular(modules: LGNotificationModular) -> NotificationType {
        return .modular(modules: modules)
    }
}
