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
    let type: String
    let campaignType: String?
    let modules: NotificationModular
    
    init(objectId: String?, createdAt: Date, isRead: Bool, type: String, campaignType: String?, modules: LGNotificationModular) {
        self.objectId = objectId
        self.createdAt = createdAt
        self.isRead = isRead
        self.type = type
        self.campaignType = campaignType
        self.modules = modules
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
        guard let data: JSON = j.decode("data") else { return Decoded<LGNotificationModular>.fromOptional(nil) }
        
        let result1 = curry(LGNotification.init)
        let result2 = result1 <^> j <|? "uuid"
        let result3 = result2 <*> j <| "created_at"
        let result4 = result3 <*> j <| "is_read"
        let result5 = result4 <*> j <| "type"
        let result6 = result5 <*> j <|? "campaign_type"
        let result  = result6 <*> LGNotificationModular.decode(data)
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGNotification parse error: \(error)")
        }
        return result
    }
}
