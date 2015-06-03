//
//  LGProductsResponseParser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import SwiftyJSON

public class LGProductsResponseParser {

    // Constant
    private static let dataJSONKey = "data"
    private static let infoJSONKey = "info"
    private static let totalProductsJSONKey = "total_products"
    private static let offsetJSONKey = "offset"
    
    // MARK: - Lifecycle
    

//        {
//            "data": [
//            {
//                "object_id": "QGZ82PutUc",
//                "category_id": "8",
//                "name": "Little Dirt Devil",
//                "description": "Teal hand vaccum in great shape.",
//                "price": "50",
//                "currency": "USD",
//                "created_at": "2015-03-26 12:25:22",
//                "status": "1",
//                "img_url_thumb": "/75/1f/05/75/f547ed6c0e9abc5881ea33014a315ab1_thumb.jpg",
//                "latitude": 40.7459,
//                "longitude": -73.9999281,
//                "distance_type": "KM",
//                "country_code": "US",
//                "language_code": "en",
//                "city": "New York City",
//                "updated_at": "2015-05-21 14:17:45",
//                "distance": "0.8834877865109788",
//                "product_images": [
//                    "http://devel.cdn.letgo.com/images/75/1f/05/75/f547ed6c0e9abc5881ea33014a315ab1.jpg"
//                ],
//                "user": {
//                    "object_id": "AMgQYjA6C8",
//                    "public_username": "Amy C.",
//                    "city": "New York City",
//                    "country_code": "US"
//                },
//                "image_dimensions": {
//                    "width": 200,
//                    "height": 149
//                }
//            },
//            ...
//            ],
//            "info": {
//                "total_products": "960",
//                "offset": "0"
//            }
//    }
    public static func responseWithJSON(json: JSON) -> LGProductsResponse? {
        var response = LGProductsResponse()
        if let data = json[LGProductsResponseParser.dataJSONKey].array {
            let products = NSMutableArray()
            for productJson in data {
                products.addObject(LGProductParser.productWithJSON(productJson))
            }
            response.products = products
        }
        let pagingInfo = json[LGProductsResponseParser.infoJSONKey]
        if let totalProducts = pagingInfo[LGProductsResponseParser.totalProductsJSONKey].string?.toInt() {
            response.totalProducts = totalProducts
        }
        else {
            return nil
        }
        if let offset = pagingInfo[LGProductsResponseParser.offsetJSONKey].string?.toInt() {
            response.offset = offset
        }
        else {
            return nil
        }
        return response
    }

}