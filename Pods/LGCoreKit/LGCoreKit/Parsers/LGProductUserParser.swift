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
    private static let idJSONKey = "id"
    
    private static let nameJSONKey = "name"
    private static let avatarURLJSONKey = "avatar_url"
    
    private static let countryCodeJSONKey = "country_code"
    private static let cityJSONKey = "city"
    private static let zipCodeJSONKey = "zipcode"
    private static let isDummyJSONKey = "is_richy"

    //{
    //    "id": "gpPAiKx5ch-d142342134-1241243d2134",
    //    "name": "Bruce W. Fuckencio",
    //    "avatar_url": "http://files.parsetfss.com/e2e3717f-b418-4017-8c7d-7b3d301e50d4/tfss-8fb0e5e2-548f-4b3f-9a4a-a5c5a95af171-QfgBfio9Zu.jpg",
    //    "zip_code": "33948",
    //    "city": "Gotham",
    //    "country_code": "ES",
    //    "is_richy": false
    //}
    public static func userWithJSON(json: JSON) -> User {
        let user = LGUser()
        user.objectId = json[LGProductUserParser.idJSONKey].string
        user.publicUsername = json[LGProductUserParser.nameJSONKey].string
        if let avatarURLStr = json[LGProductUserParser.avatarURLJSONKey].string {
            user.avatar = LGFile(url: NSURL(string: avatarURLStr))
        }
        let postalAddress = PostalAddress()
        postalAddress.countryCode = json[LGProductUserParser.countryCodeJSONKey].string
        postalAddress.city = json[LGProductUserParser.cityJSONKey].string
        postalAddress.zipCode = json[LGProductUserParser.zipCodeJSONKey].string
        postalAddress.address = nil
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