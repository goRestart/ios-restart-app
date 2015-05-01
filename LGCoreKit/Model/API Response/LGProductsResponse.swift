//
//  LGProductsResponse.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public struct LGProductsResponse {
    
    // Constant
    // > JSON keys
    private static let dataJSONKey = "data"
    private static let infoJSONKey = "info"
    private static let totalProductsJSONKey = "total_products"
    private static let offsetJSONKey = "offset"
    
    // iVars
    public var products: [LGPartialProduct]
    public var totalProducts: Int?
    public var offset: Int?
    
    // MARK: - Lifecycle
    
    //{
    //  "data": [
    //      {
    //          "object_id": "fZPmJ2dgF5",
    //          "category_id": "6",
    //          "name": "Women's wedge sandals",
    //          "price": "15",
    //          "currency": "USD",
    //          "created_at": "2015-04-21 14:39:17",
    //          "status": "1",
    //          "img_url_thumb": "/cc/71/f9/c1/4991cf93b3be50f8da116401d33b9e37_thumb.jpg",
    //          "distance_type": "KM",
    //          "image_dimensions": {
    //              "width": 200,
    //              "height": 150
    //          }
    //      },...
    //  ],
    //  "info": {
    //      "total_products": "475",
    //      "offset": "0"
    //  }
    //}
    public init?(json: JSON) {
        
        self.products = []
        if let data = json[LGProductsResponse.dataJSONKey].array {
            for productJson in data {
                self.products.append(LGPartialProduct(json: productJson))
            }
        }
        self.totalProducts = json[LGProductsResponse.infoJSONKey][LGProductsResponse.totalProductsJSONKey].string?.toInt()
        self.offset = json[LGProductsResponse.infoJSONKey][LGProductsResponse.offsetJSONKey].string?.toInt()
    }
}
