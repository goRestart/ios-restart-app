//
//  LGPassiveBuyersInfo.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGPassiveBuyersInfo: PassiveBuyersInfo {
    let objectId: String?
    let productImage: File?
    let passiveBuyers: [PassiveBuyersUser]

    init(objectId: String?, productImage: String?, passiveBuyers: [LGPassiveBuyersUser]) {
        self.objectId = objectId
        self.productImage = LGFile(id: nil, urlString: productImage)
        self.passiveBuyers = passiveBuyers.flatMap { $0 }
    }
}

extension LGPassiveBuyersInfo: Decodable {
    /**
    {
    	"product_id": "c06edf71-fd46-4207-9690-1412d1b22dd0",
    	"product_image": "http:\/\/test\/images\/test.jpeg",
    	"passive_buyer_users": [{
    		"user_id": "1234567890",
    		"username": "username0",
    		"avatar": "http:\/\/test\/avatar0.jpg"
    	}, {
    		"user_id": "2234567891",
    		"username": "username1",
    		"avatar": "http:\/\/test\/avatar1.jpg"
    	}, {
    		"user_id": "3234567892",
    		"username": "username2",
    		"avatar": "http:\/\/test\/avatar2.jpg"
    	}, {
    		"user_id": "3234567893",
    		"username": "username3",
    		"avatar": "http:\/\/test\/avatar3.jpg"
    	}]
    }
     */
    static func decode(j: JSON) -> Decoded<LGPassiveBuyersInfo> {
        let result = curry(LGPassiveBuyersInfo.init)
            <^> j <|? "product_id"
            <*> j <|? "product_image"
            <*> j <|| "passive_buyer_users"

        if let error = result.error {
            logMessage(.Error, type: CoreLoggingOptions.Parsing, message: "LGPassiveBuyersInfo parse error: \(error)")
        }
        return result
    }
}
