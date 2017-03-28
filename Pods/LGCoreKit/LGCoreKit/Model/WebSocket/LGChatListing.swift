//
//  LGChatListing.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChatListing: ChatListing {
    let objectId: String?
    let name: String?
    let status: ListingStatus
    let image: File?
    let price: ProductPrice
    let currency: Currency
    
    init(objectId: String?, name: String?, status: Int, image: File?, price: Double?, priceFlag: ProductPriceFlag?,
         currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = ListingStatus(rawValue: status) ?? .pending
        self.image = image
        self.price = ProductPrice.fromPrice(price, andFlag: priceFlag)
        self.currency = currency
    }
}

extension LGChatListing: Decodable {
    
    struct JSONKeys {
        static let objectId = "id"
        static let name = "name"
        static let status = "status"
        static let image = "image"
        static let price = ["price", "amount"]
        static let priceFlag = [ "price", "flag" ]
        static let currency = ["price", "currency"]
    }
    
    static func decode(_ j: JSON) -> Decoded<LGChatListing> {
        let init1 = curry(LGChatListing.init)
            <^> j <|? JSONKeys.objectId
            <*> j <|? JSONKeys.name
            <*> j <| JSONKeys.status
            <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.image)
            <*> j <|? JSONKeys.price
            <*> j <|? JSONKeys.priceFlag
            <*> LGArgo.jsonToCurrency(j, currencyKey: JSONKeys.currency)

        if let error = init1.error {
            logMessage(.error, type: .parsing, message: "LGChatListing parse error: \(error)")
        }
        return init1
    }
    
    static func decodeOptional(_ json: JSON?) -> Decoded<LGChatListing?> {
        guard let j = json else { return Decoded<LGChatListing?>.success(nil) }
        return Decoded<LGChatListing?>.success(LGChatListing.decode(j).value)
    }
}
