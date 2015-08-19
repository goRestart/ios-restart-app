//
//  LGProductUserParser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGProductUserParser {
    
    // Constant
    // > JSON keys
    private static let objectIdJSONKey = "object_id"
    
    private static let publicUsernameJSONKey = "public_username"
    private static let avatarURLJSONKey = "avatar"
    
    private static let countryCodeJSONKey = "country_code"
    private static let cityJSONKey = "city"
    private static let zipCodeJSONKey = "zipcode"
    private static let isDummyJSONKey = "is_richy"
    
//    {
//        "object_id": "WHmGjAxX8L",
//        "public_username": "Valy F.",
//        "avatar": "http://files.parsetfss.com/abbc9384-9790-4bbb-9db2-1c3522889e96/tfss-bcc7eccf-7b18-4ed7-9b87-7c6d3925e39b-WHmGjAxX8L.jpg",
//        "zipcode": "08002",
//        "city": "Barcelona",
//        "country_code": "ES",
//        "is_richy": true
//    }
    public static func userWithJSON(json: JSON) -> User {
        let user = LGUser()
        user.objectId = json[LGProductUserParser.objectIdJSONKey].string
        user.publicUsername = json[LGProductUserParser.publicUsernameJSONKey].string
        if let avatarURLStr = json[LGProductUserParser.avatarURLJSONKey].string {
            user.avatar = LGFile(url: NSURL(string: avatarURLStr))
        }
        
        let postalAddress = PostalAddress()
        postalAddress.countryCode = json[LGProductUserParser.countryCodeJSONKey].string
        postalAddress.city = json[LGProductUserParser.cityJSONKey].string
        postalAddress.zipCode = json[LGProductUserParser.zipCodeJSONKey].string
        user.postalAddress = postalAddress
        
        if let isDummy = json[LGProductUserParser.isDummyJSONKey].bool {
            user.isDummy = isDummy
        }
        else {
            user.isDummy = false
        }
        
        return user
    }
}