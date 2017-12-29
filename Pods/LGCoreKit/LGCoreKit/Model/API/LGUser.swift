//
//  LGUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGUser: User {

    // Global iVars
    let objectId: String?

    // User iVars
    let name: String?
    let avatar: File?
    let postalAddress: PostalAddress

    let ratingAverage: Float?
    let ratingCount: Int
    let accounts: [Account]

    let status: UserStatus

    var isDummy: Bool

    var phone: String?
    var type: UserType


    init(objectId: String?, name: String?, avatar: String?, postalAddress: PostalAddress, ratingAverage: Float?,
         ratingCount: Int, accounts: [LGAccount], status: UserStatus?, isDummy: Bool, phone: String?, type: UserType) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
        self.postalAddress = postalAddress
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.accounts = accounts
        self.status = status ?? .active
        self.isDummy = isDummy
        self.phone = phone
        self.type = type
    }
    
    init(chatInterlocutor: ChatInterlocutor) {
        let postalAddress = PostalAddress.emptyAddress()
        self.init(objectId: chatInterlocutor.objectId, name: chatInterlocutor.name,
                  avatar: chatInterlocutor.avatar?.fileURL?.absoluteString,
                  postalAddress: postalAddress, ratingAverage: nil, ratingCount: 0, accounts: [],
                  status: chatInterlocutor.status, isDummy: false, phone: nil,
                  type: .user)
    }
}


extension LGUser : Decodable {

    /**
    Decodes a json in the form:
    {
    	"id": "d67a38d4-6a80-4ca7-a54e-ccf0c57076a3",
    	"latitude": 40.713054,
    	"longitude": -74.007228,
    	"username": "119750508403100",      // not parsed
    	"name": "Sara G.",
    	"email": "aras_0212@hotmail.com",
        "phone": string,
        "type": string ("professional"/"user"),
    	"avatar_url": "https:\/\/s3.amazonaws.com\/letgo-avatars-pro\/images\/98\/ef\/d3\/4a\/98efd34ae8ba6a879dba60706152b131b8a64d45bf0c4ae043a39caa5d3774bc.jpg",
    	"zip_code": "",
    	"address": "New York NY",
    	"city": "New York",
    	"country_code": "US",
    	"is_richy": false,
        "rating_value": "number"|null,      // an unrated user or one whose ratings have been deleted will have a null
        "num_ratings": "integer",           // an unrated user or one whose ratings have been deleted will have a 0
    	"accounts": [{
    		"type": "facebook",
    		"verified": false
    	}, {
    		"type": "letgo",
    		"verified": true
    	}],
        "status": "active"
    }
    */
    static func decode(_ j: JSON) -> Decoded<LGUser> {
        let result1 = curry(LGUser.init)
        let result2 = result1 <^> j <|? "id"
        let result3 = result2 <*> j <|? "name"
        let result4 = result3 <*> j <|? "avatar_url"
        let result5 = result4 <*> PostalAddress.decode(j)
        let result6 = result5 <*> j <|? "rating_value"
        let result7 = result6 <*> j <| "num_ratings"
        let result8 = result7 <*> j <|| "accounts"
        let result9 = result8 <*> j <|? "status"
        let result10  = result9 <*> LGArgo.mandatoryWithFallback(json: j, key: "is_richy", fallback: false)
        let result11 = result10 <*> j <|? "phone"
        let result = result11 <*> j <| "type"

        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGUser parse error: \(error)")
        }
        return result
    }
}
