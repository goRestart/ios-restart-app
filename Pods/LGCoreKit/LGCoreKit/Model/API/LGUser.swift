//
//  LGUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct LGUser: User {
    
    // Global iVars
    public var objectId: String?
    
    // User iVars
    public var publicUsername: String?
    public var avatar: File?
    public var postalAddress: PostalAddress
    public var isDummy: Bool
    
    init(objectId: String?, publicUsername: String?, avatar: String?, postalAddress: PostalAddress, isDummy: Bool) {
        self.objectId = objectId
        self.publicUsername = publicUsername
        self.avatar = LGFile(string: avatar)
        self.postalAddress = postalAddress
        self.isDummy = isDummy
    }
}

extension LGUser {
    // Lifecycle
    public init() {
        self.postalAddress = PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
        self.isDummy = false
    }
}

extension LGUser : Decodable {
    
    /**
    Expects a json in the form:
    
        {
            "id": "gpPAiKx5ch-d142342134-1241243d2134",
            "name": "Bruce W. Fuckencio",
            "avatar_url": "http://files.parsetfss.com/e2e3717f-b418-4017-8c7d-7b3d301e50d4/tfss-8fb0e5e2-548f-4b3f-9a4a-a5c5a95af171-QfgBfio9Zu.jpg",
            "zip_code": "33948",
            "city": "Gotham",
            "country_code": "ES",
            "is_richy": false
        }
    */
    public static func decode(j: JSON) -> Decoded<LGUser> {
        
        //Rest of object passing the resulting avatar
        let result = curry(LGUser.init)
            <^> j <|? "id"
            <*> j <|? "name"
            <*> j <|? "avatar_url"
            <*> PostalAddress.decode(j)
            <*> LGArgo.mandatoryWithFallback(json: j, key: "is_richy", fallback: false)
        
        if let error = result.error {
            print("LGUser parse error: \(error)")
        }
        
        return result
    }
}