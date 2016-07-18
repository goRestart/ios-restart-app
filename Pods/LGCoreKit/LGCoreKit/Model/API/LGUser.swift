//
//  LGUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGUser: User {

    // Global iVars
    var objectId: String?

    // User iVars
    var name: String?
    var avatar: File?
    var postalAddress: PostalAddress
    var accounts: [Account]?    // TODO: When switching to bouncer only make accounts non-optional
    var status: UserStatus
    var isDummy: Bool


    init(objectId: String?, name: String?, avatar: String?, postalAddress: PostalAddress, accounts: [LGAccount]?,
         status: UserStatus?, isDummy: Bool) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
        self.postalAddress = postalAddress
        self.accounts = accounts?.map { $0 as Account }
        self.status = status ?? .Active
        self.isDummy = isDummy
    }
    
    init(chatInterlocutor: ChatInterlocutor) {
        let postalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.init(objectId: chatInterlocutor.objectId, name: chatInterlocutor.name,
                  avatar: chatInterlocutor.avatar?.fileURL?.absoluteString,
                  postalAddress: postalAddress, accounts: nil,
                  status: chatInterlocutor.status, isDummy: false)
    }
}

extension LGUser {
    // Lifecycle
    init() {
        let postalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.init(objectId: nil, name: nil, avatar: nil, postalAddress: postalAddress, accounts: nil,
                  status: .Active, isDummy: false)
    }
}

extension LGUser : Decodable {

    /**
    Decodes a json in the form:
    {
    	"id": "d67a38d4-6a80-4ca7-a54e-ccf0c57076a3",
    	"latitude": 40.713054,
    	"longitude": -74.007228,
    	"username": "119750508403100",        // not parsed
    	"name": "Sara G.",
    	"email": "aras_0212@hotmail.com",
    	"avatar_url": "https:\/\/s3.amazonaws.com\/letgo-avatars-pro\/images\/98\/ef\/d3\/4a\/98efd34ae8ba6a879dba60706152b131b8a64d45bf0c4ae043a39caa5d3774bc.jpg",
    	"zip_code": "",
    	"address": "New York NY",
    	"city": "New York",
    	"country_code": "US",
    	"is_richy": false,
    	"accounts": [{
    		"type": "facebook",
    		"verified": false
    	}, {
    		"type": "letgo",
    		"verified": true
    	}]
    }
    */
    static func decode(j: JSON) -> Decoded<LGUser> {
        let result = curry(LGUser.init)
            <^> j <|? "id"
            <*> j <|? "name"
            <*> j <|? "avatar_url"
            <*> PostalAddress.decode(j)
            <*> j <||? "accounts"
            <*> j <|? "status"
            <*> LGArgo.mandatoryWithFallback(json: j, key: "is_richy", fallback: false)

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGUser parse error: \(error)")
        }

        return result
    }
}
