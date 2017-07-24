//
//  LGUserListing.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/01/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGUserListing: UserListing {
    
    // Global iVars
    let objectId: String?
    
    // User iVars
    let name: String?
    let avatar: File?
    let postalAddress: PostalAddress
    let isDummy: Bool
    let banned: Bool?
    let status: UserStatus
    
    
    init(objectId: String?, name: String?, avatar: String?, postalAddress: PostalAddress, isDummy: Bool,
         banned: Bool?, status: UserStatus?) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
        self.postalAddress = postalAddress
        self.isDummy = isDummy
        self.banned = banned
        self.status = status ?? .active
    }
    
    init(chatInterlocutor: ChatInterlocutor) {
        let postalAddress = PostalAddress.emptyAddress()
        self.init(objectId: chatInterlocutor.objectId, name: chatInterlocutor.name,
                  avatar: chatInterlocutor.avatar?.fileURL?.absoluteString,
                  postalAddress: postalAddress, isDummy: false, banned: false, status: chatInterlocutor.status)
    }
    
    init(user: User) {
        self.init(objectId: user.objectId, name: user.name, avatar: user.avatar?.fileURL?.absoluteString,
                  postalAddress: user.postalAddress, isDummy: user.isDummy, banned: false, status: user.status)
    }
}

extension LGUserListing : Decodable {
    
    /**
     "owner": {
     "id": "DCOefspN3I",
     "name": "DDLG",
     "avatar_url": "https://s3.amazonaws.com/letgo-avatars-stg/images/15/a4/db/90/15a4db909cb440d02c31d3596726d83f7801112f058f0c5c5b3e9585eac7d143.jpg",
     "zip_code": "",
     "country_code": "ES",
     "is_richy": false,
     "city": "",
     "banned": false,
     "status": "active"
     },     */
    
    static func decode(_ j: JSON) -> Decoded<LGUserListing> {
        let result1 = curry(LGUserListing.init)
        let result2 = result1 <^> j <|? "id"
        let result3 = result2 <*> j <|? "name"
        let result4 = result3 <*> j <|? "avatar_url"
        let result5 = result4 <*> PostalAddress.decode(j)
        let result6 = result5 <*> LGArgo.mandatoryWithFallback(json: j, key: "is_richy", fallback: false)
        let result7 = result6 <*> j <|? "banned"
        let result  = result7 <*> j <|? "status"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGUserListing parse error: \(error)")
        }
        return result
    }
}
