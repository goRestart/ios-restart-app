//
//  LGProductsResponse.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGProductsResponse: ProductsResponse, ResponseObjectSerializable {
    
    // Constant
    private static let dataJSONKey = "data"
    private static let infoJSONKey = "info"
    private static let totalProductsJSONKey = "total_products"
    private static let offsetJSONKey = "offset"
    
    public var products: NSArray
    public var totalProducts: NSNumber
    public var offset: NSNumber
    
    public var lastPage: NSNumber {
        get {
            let isLastPage = products.count + offset.intValue >= totalProducts.intValue
            return NSNumber(bool: isLastPage)
        }
    }
    
    // MARK: - Lifecycle
    
    public init() {
        products = []
        totalProducts = NSNumber(integer: 0)
        offset = NSNumber(integer: 0)
    }
    
    // MARK: - ResponseObjectSerializable
    
//    {
//        "data": [...],
//        "info": {
//            "total_products": "960",
//            "offset": "0"
//        }
//    }
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        let parsedProducts = NSMutableArray()
        if let data = json[LGProductsResponse.dataJSONKey].array {

            let countryCurrencyInfoDao = RLMCountryCurrencyInfoDAO()
            let currencyHelper = CurrencyHelper(countryCurrencyInfoDAO: countryCurrencyInfoDao)
            
            for productJson in data {
                parsedProducts.addObject(LGProductParser.productWithJSON(productJson, currencyHelper: currencyHelper))
            }
        }
        products = parsedProducts
        
        let pagingInfo = json[LGProductsResponse.infoJSONKey]
        if let actualTotalProducts = pagingInfo[LGProductsResponse.totalProductsJSONKey].string?.toInt() {
            totalProducts = actualTotalProducts
        }
        else if let actualTotalProducts = pagingInfo[LGProductsResponse.totalProductsJSONKey].int {
            totalProducts = actualTotalProducts
        }
        else {
            return nil
        }
        
        if let actualOffset = pagingInfo[LGProductsResponse.offsetJSONKey].string?.toInt() {
            offset = actualOffset
        }
        else if let actualOffset = pagingInfo[LGProductsResponse.offsetJSONKey].int {
            offset = actualOffset
        }
        else {
            return nil
        }
    }
}