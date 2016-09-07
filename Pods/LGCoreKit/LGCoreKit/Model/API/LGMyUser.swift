//
//  LGMyUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import CoreLocation
import Curry
import Foundation


// MARK: - LGMyUser

struct LGMyUser: MyUser {
    // BaseModel
    var objectId: String?

    // User
    var name: String?
    var avatar: File?
    var postalAddress: PostalAddress
    var accounts: [Account]?
    var ratingAverage: Float?
    var ratingCount: Int?
    var status: UserStatus

    // MyUser
    var email: String?
    var location: LGLocation?

    init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, accounts: [LGAccount]?,
         ratingAverage: Float?, ratingCount: Int?, status: UserStatus?, email: String?, location: LGLocation?) {
        self.objectId = objectId

        self.name = name
        self.avatar = avatar
        self.postalAddress = postalAddress

        self.accounts = accounts?.map { $0 as Account }
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount

        self.status = status ?? .Active

        self.email = email
        self.location = location
    }
}


// MARK: - Decodable

extension LGMyUser: Decodable {
    struct JSONKeys {
        static let objectId = "id"
        static let name = "name"
        static let email = "email"
        static let password = "password"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let locationType = "location_type"
        static let avatar = "avatar_url"
        static let address = "address"
        static let city = "city"
        static let zipCode = "zip_code"
        static let countryCode = "country_code"
        static let newsletter = "newsletter"
        static let ratingAverage = "rating_value"
        static let ratingCount = "num_ratings"
        static let accounts = "accounts"
        static let status = "status"
    }

    /**
    https://ambatana.atlassian.net/wiki/display/BAPI/Users
    Decodes a json in the form:
    {
    	"id": "d67a38d4-6a80-4ca7-a54e-ccf0c57076a3",
    	"latitude": 40.713054,
    	"longitude": -74.007228,
    	"username": "119750508403100",      // not parsed
    	"name": "Sara G.",
    	"email": "aras_0212@hotmail.com",
    	"avatar_url": "https:\/\/s3.amazonaws.com\/letgo-avatars-pro\/images\/98\/ef\/d3\/4a\/98efd34ae8ba6a879dba60706152b131b8a64d45bf0c4ae043a39caa5d3774bc.jpg",
    	"zip_code": "",
    	"address": "New York NY",
    	"city": "New York",
    	"country_code": "US",
    	"is_richy": false,
        "rating_value": "number"|null,
        "num_ratings": "integer",
    	"accounts": [{
    		"type": "facebook",
    		"verified": false
    	}, {
    		"type": "letgo",
    		"verified": true
    	}]
    }
    */
    static func decode(j: JSON) -> Decoded<LGMyUser> {
        let init1 = curry(LGMyUser.init)
                            <^> j <|? JSONKeys.objectId
                            <*> j <|? JSONKeys.name
                            <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.avatar)
                            <*> PostalAddress.decode(j)
        let init2 = init1   <*> j <||? JSONKeys.accounts
                            <*> j <|? JSONKeys.ratingAverage
                            <*> j <|? JSONKeys.ratingCount
                            <*> j <|? JSONKeys.status
                            <*> j <|? JSONKeys.email
                            <*> LGArgo.jsonToLocation(j, latKey: JSONKeys.latitude, lonKey: JSONKeys.longitude,
                                      typeKey: JSONKeys.locationType)

        if let error = init2.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGMyUser parse error: \(error)")
        }
        return init2
    }
}
