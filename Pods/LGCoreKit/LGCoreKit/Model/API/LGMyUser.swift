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

    // MyUser
    var email: String?
    var location: LGLocation?

    var authProvider: AuthenticationProvider
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
        static let avatar = "avatar_url"
        static let address = "address"
        static let city = "city"
        static let zipCode = "zip_code"
        static let countryCode = "country_code"
    }

    /**
    Decodes a json with the following format:

    {
        "id": "string",
        "latitude": 0,
        "longitude": 0,
        "username": "string",           // not parsed
        "email": "string",
        "name": "string",
        "avatar_url": "string",
        "zip_code": "string",
        "address": "string",
        "city": "string",
        "country_code": "string"
    }
    */
    static func decode(j: JSON) -> Decoded<LGMyUser> {
        let init1 = curry(LGMyUser.init)
                            <^> j <|? JSONKeys.objectId
                            <*> j <|? JSONKeys.name
                            <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.avatar)
                            <*> PostalAddress.decode(j)
        let init2 = init1   <*> j <|? JSONKeys.email
                            <*> LGArgo.jsonToLocation(j, latKey: JSONKeys.latitude, lonKey: JSONKeys.longitude)
                            <*> Decoded<AuthenticationProvider>.Success(.Unknown)   // does not come from API
        return init2
    }
}
