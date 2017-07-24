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
    let price: ListingPrice
    let currency: Currency
    
    init(objectId: String?,
         name: String?,
         status: Int,
         image: File?,
         price: Double?,
         priceFlag: ListingPriceFlag?,
         currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = ListingStatus(rawValue: status) ?? .pending
        self.image = image
        self.price = ListingPrice.fromPrice(price, andFlag: priceFlag)
        self.currency = currency
    }
    
    init(objectId: String?,
         name: String?,
         status: ListingStatus,
         image: File?,
         price: ListingPrice,
         currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = status
        self.image = image
        self.price = price
        self.currency = currency
    }
    
    fileprivate static func make(objectId: String?,
                                 name: String?,
                                 status: Int,
                                 image: LGFile?,
                                 price: Double?,
                                 priceFlag: ListingPriceFlag?,
                                 currency: Currency) -> LGChatListing {
        return LGChatListing(objectId: objectId,
                             name: name,
                             status: status,
                             image: image,
                             price: price,
                             priceFlag: priceFlag,
                             currency: currency)
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
        let result1 = curry(LGChatListing.make)
        let result2 = result1 <^> j <|? JSONKeys.objectId
        let result3 = result2 <*> j <|? JSONKeys.name
        let result4 = result3 <*> j <| JSONKeys.status
        let result5 = result4 <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.image)
        let result6 = result5 <*> j <|? JSONKeys.price
        let result7 = result6 <*> j <|? JSONKeys.priceFlag
        let result  = result7 <*> LGArgo.jsonToCurrency(j, currencyKey: JSONKeys.currency)
        if let error = result.error {
            logMessage(.error, type: .parsing, message: "LGChatListing parse error: \(error)")
        }
        return result
    }
    
    static func decodeOptional(_ json: JSON?) -> Decoded<LGChatListing?> {
        guard let j = json else { return Decoded<LGChatListing?>.success(nil) }
        return Decoded<LGChatListing?>.success(LGChatListing.decode(j).value)
    }
}
