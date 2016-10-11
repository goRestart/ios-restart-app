//
//  LGChatProduct.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGChatProduct: ChatProduct {
    let objectId: String?
    let name: String?
    let status: ProductStatus
    let image: File?
    let price: ProductPrice
    let currency: Currency
    
    init(objectId: String?, name: String?, status: Int, image: File?, price: Double?, priceFlag: ProductPriceFlag?,
         currency: Currency) {
        self.objectId = objectId
        self.name = name
        self.status = ProductStatus(rawValue: status) ?? .Pending
        self.image = image
        self.price = ProductPrice.fromPrice(price, andFlag: priceFlag)
        self.currency = currency
    }
}

extension LGChatProduct: Decodable {
    
    struct JSONKeys {
        static let objectId = "id"
        static let name = "name"
        static let status = "status"
        static let image = "image"
        static let price = ["price", "amount"]
        static let priceFlag = [ "price", "flag" ]
        static let currency = ["price", "currency"]
    }
    
    static func decode(j: JSON) -> Decoded<LGChatProduct> {
        let init1 = curry(LGChatProduct.init)
            <^> j <|? JSONKeys.objectId
            <*> j <|? JSONKeys.name
            <*> j <| JSONKeys.status
            <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.image)
            <*> j <|? JSONKeys.price
            <*> j <|? JSONKeys.priceFlag
            <*> LGArgo.jsonToCurrency(j, currencyKey: JSONKeys.currency)
        
        return init1
    }
    
    static func decodeOptional(json: JSON?) -> Decoded<LGChatProduct?> {
        guard let j = json else { return Decoded<LGChatProduct?>.Success(nil) }
        return Decoded<LGChatProduct?>.Success(LGChatProduct.decode(j).value)
    }
}
