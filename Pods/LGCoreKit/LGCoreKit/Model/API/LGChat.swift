//
//  LGChat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChat: Chat {

    // Global iVars
    var objectId: String?
    let updatedAt: Date?

    // Chat iVars
    let listing: Listing
    let userFrom: UserListing
    let userTo: UserListing
    let msgUnreadCount: Int
    let messages: [Message]
    let forbidden: Bool
    let archivedStatus: ChatArchivedStatus
}

extension LGChat : Decodable {

    static func newLGChat(_ objectId: String?, updatedAt: Date?, listing: Listing, userFrom: LGUserListing,
        userTo: LGUserListing, msgUnreadCount: Int, messages: [LGMessage]?, forbidden: Bool, status: Int) -> LGChat {

            let theMessages : [Message]
            if let actualMessages = messages {
                theMessages = actualMessages.map({$0})
            }
            else{
                theMessages = []
            }
            let archivedStatus = ChatArchivedStatus(rawValue: status) ?? .active
            return LGChat(objectId: objectId, updatedAt: updatedAt, listing: listing, userFrom: userFrom,
                userTo: userTo, msgUnreadCount: msgUnreadCount, messages: theMessages, forbidden: forbidden,
                archivedStatus: archivedStatus)
    }

    /**
    Expects a json in the form:

        {
            "id": "ca0dd7da-0162-4c06-a8dc-c094bbfc7fe3",
            "listing": Listing,
            "user_to": LGUser,
            "user_from": LGUser,
            "unread_count": 0,
            "updated_at": "2015-09-11T09:02:07+0000",
            "messages": [LGMessage],
            "forbidden": false,
            "status": 0
    }
    
    */
    static func decode(_ j: JSON) -> Decoded<LGChat> {
        let result1 = curry(LGChat.newLGChat)
        let result2 = result1 <^> j <|? "id"
        let result3 = result2 <*> j <|? "updated_at"
        let result4 = result3 <*> j <| "product"
        let result5 = result4 <*> j <| "user_from"
        let result6 = result5 <*> j <| "user_to"
        let result7 = result6 <*> LGArgo.mandatoryWithFallback(json: j, key: "unread_count", fallback: 0)
        let result8 = result7 <*> j <||? "messages"
        let result9 = result8 <*> j <| "forbidden"
        let result  = result9 <*> j <| "status"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGChat parse error: \(error)")
        }
        return result
    }
}
