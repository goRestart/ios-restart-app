//
//  LGChatParser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGChatParser {

    // Constant
    // > JSON keys
    private static let objectIdJSONKey = "id"
    private static let updatedAtJSONKey = "updated_at"
    
    private static let productJSONKey = "product"
    private static let userToJSONKey = "user_to"
    private static let userFromJSONKey = "user_from"
    private static let unreadCountJSONKey = "unread_count"
    private static let messagesJSONKey = "messages"
    
    //[
    //    {
    //        "id": "ca0dd7da-0162-4c06-a8dc-c094bbfc7fe3",
    //        "product": ...,
    //        "user_to": ...,
    //        "user_from": ...,
    //        "unread_count": 0,
    //        "updated_at": "2015-09-11T09:02:07+0000",
    //        "messages": ...
    //    },
    //    ...
    //]
    public static func chatWithJSON(json: JSON, currencyHelper: CurrencyHelper, distanceType: DistanceType) -> LGChat {
        let chat = LGChat()
        chat.objectId = json[LGChatParser.objectIdJSONKey].string
        if let updatedAtStr = json[LGChatParser.updatedAtJSONKey].string, let date = LGDateFormatter.sharedInstance.dateFromString(updatedAtStr) {
            chat.updatedAt = date
        }
        let productJSON = json[LGChatParser.productJSONKey]
        chat.product = LGProductParser.productWithJSON(productJSON, currencyHelper: currencyHelper, distanceType: distanceType)
        chat.userFrom = LGProductUserParser.userWithJSON(json[LGChatParser.userToJSONKey])
        chat.userTo = LGProductUserParser.userWithJSON(json[LGChatParser.userFromJSONKey])
        chat.msgUnreadCount = json[LGChatParser.unreadCountJSONKey].int

        if let messagesJSON = json[LGChatParser.messagesJSONKey].array {
            var messages: [Message] = []
            for messageJSON in messagesJSON {
                let message = LGMessageParser.messageWithJSON(messageJSON)
                messages.append(message)
            }
            chat.messages = messages
        }
        return chat
    }
}
