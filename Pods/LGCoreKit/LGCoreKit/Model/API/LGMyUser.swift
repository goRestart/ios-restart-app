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
import Runes

protocol LGMyUserKeys {
    var objectId: String { get }
    var name: String { get }
    var email: String { get }
    var latitude: String { get }
    var longitude: String { get }
    var locationType: String { get }
    var avatar: String { get }
    var address: String { get }
    var city: String { get }
    var zipCode: String { get }
    var state: String { get }
    var countryCode: String { get }
    var ratingAverage: String { get }
    var ratingCount: String { get }
    var accounts: String { get }
    var status: String { get }
    var phone: String { get }
    var type: String { get }
    var localeIdentifier: String { get }
}

protocol LGMyUserApiKeys: LGMyUserKeys {
    var password: String { get }
    var newsletter: String { get }
}


// MARK: - LGMyUser

struct LGMyUser: MyUser {

    // BaseModel
    var objectId: String?

    // User
    var name: String?
    var avatar: File?
    var accounts: [Account]
    var ratingAverage: Float?
    var ratingCount: Int
    var status: UserStatus

    var phone: String?
    var type: UserType

    // MyUser
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?

    init(objectId: String?, name: String?, avatar: LGFile?, accounts: [LGAccount],
         ratingAverage: Float?, ratingCount: Int, status: UserStatus?, phone: String?, type: UserType?,
         email: String?, location: LGLocation?, localeIdentifier: String?) {
        self.objectId = objectId

        self.name = name
        self.avatar = avatar
        
        self.accounts = accounts
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount

        self.status = status ?? .active

        self.phone = phone
        self.type = type ?? .user

        self.email = email
        self.location = location
        self.localeIdentifier = localeIdentifier
    }
}


// MARK: - Decodable

extension LGMyUser: Decodable {
    struct ApiMyUserKeys: LGMyUserApiKeys {
        let objectId = "id"
        let name = "name"
        let email = "email"
        let password = "password"
        let latitude = "latitude"
        let longitude = "longitude"
        let locationType = "location_type"
        let avatar = "avatar_url"
        let address = "address"
        let city = "city"
        let state = "state"
        let zipCode = "zip_code"
        let countryCode = "country_code"
        let newsletter = "newsletter"
        let ratingAverage = "rating_value"
        let ratingCount = "num_ratings"
        let accounts = "accounts"
        let status = "status"
        let phone = "phone"
        let type = "type"
        let localeIdentifier = "locale"
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
        "phone": string,
        "type": string ("professional"/"user"),
    	"avatar_url": "https:\/\/s3.amazonaws.com\/letgo-avatars-pro\/images\/98\/ef\/d3\/4a\/98efd34ae8ba6a879dba60706152b131b8a64d45bf0c4ae043a39caa5d3774bc.jpg",
    	"zip_code": "",
    	"address": "New York NY",
    	"city": "New York",
    	"country_code": "US",
    	"is_richy": false,
        "rating_value": "number|null",
        "num_ratings": "integer",
    	"accounts": [{
            "type": "facebook",
            "verified": false
    	}, {
            "type": "letgo",
            "verified": true
    	}],
        "locale": "string|null"
    }
    */
    static func decode(_ j: JSON) -> Decoded<LGMyUser> {
        return decode(j, keys: ApiMyUserKeys())
    }

    static func decode(_ j: JSON, keys: LGMyUserApiKeys) -> Decoded<LGMyUser> {
        let result01 = curry(LGMyUser.init)
        let result02 = result01 <^> j <|? keys.objectId
        let result03 = result02 <*> j <|? keys.name
        let result04 = result03 <*> LGArgo.jsonToAvatarFile(j, avatarKey: keys.avatar)
        let result05 = result04 <*> j <|| keys.accounts
        let result06 = result05 <*> j <|? keys.ratingAverage
        let result07 = result06 <*> j <| keys.ratingCount
        let result08 = result07 <*> j <|? keys.status
        let result09 = result08 <*> j <|? keys.phone
        let result10 = result09 <*> j <|? keys.type
        let result11 = result10 <*> j <|? keys.email
        let result12 = result11 <*> LGArgo.jsonToLocation(j, latKey: keys.latitude, lonKey: keys.longitude,
                                                          typeKey: keys.locationType)
        let result   = result12 <*> j <|? keys.localeIdentifier
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "LGMyUser parse error: \(error)")
        }
        return result
    }
}
