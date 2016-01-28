//
//  LGChat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import UIKit
import Argo
import Curry

public struct LGChat: Chat {

    // Global iVars
    public var objectId: String?
    public var updatedAt: NSDate?

    // Chat iVars
    public var product: Product
    public var userFrom: User
    public var userTo: User
    public var msgUnreadCount: Int
    public var messages: [Message]
    public var forbidden: Bool

    public mutating func prependMessage(message: Message) {
        self.messages.insert(message, atIndex: 0)
    }
}

extension LGChat : Decodable {

    private static func newLGChat(objectId: String?, updatedAt: NSDate?, product: LGProduct, userFrom: LGUser, userTo: LGUser, msgUnreadCount: Int, messages: [LGMessage]?, forbidden: Bool) -> LGChat {

        let theMessages : [Message]
        if let actualMessages = messages {
            theMessages = actualMessages.map({$0})
        }
        else{
            theMessages = []
        }

        return LGChat(objectId: objectId, updatedAt: updatedAt, product: product, userFrom: userFrom, userTo: userTo, msgUnreadCount: msgUnreadCount, messages: theMessages, forbidden: forbidden)
    }

    /**
    Expects a json in the form:

        {
            "id": "ca0dd7da-0162-4c06-a8dc-c094bbfc7fe3",
            "product": LGProduct,
            "user_to": LGUser,
            "user_from": LGUser,
            "unread_count": 0,
            "updated_at": "2015-09-11T09:02:07+0000",
            "messages": [LGMessage]
    }
    
    */
    public static func decode(j: JSON) -> Decoded<LGChat> {
        
        let init1 = curry(LGChat.newLGChat)
                            <^> j <|? "id"
                            <*> LGArgo.parseDate(json: j, key: "updated_at")
                            <*> j <| "product"
                            <*> j <| "user_from"
                            <*> j <| "user_to"
        let result = init1  <*> LGArgo.mandatoryWithFallback(json: j, key: "unread_count", fallback: 0)
                            <*> j <||? "messages"
                            <*> j <| "forbidden"
        
        if let error = result.error {
            print("LGChat parse error: \(error)")
        }

        return result
    }
}
