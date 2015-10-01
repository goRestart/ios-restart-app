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
    
    public var products: NSArray
    
    // MARK: - Lifecycle
    
    public init() {
        products = []
    }
    
    // MARK: - ResponseObjectSerializable
    
    //    [
    //        {...},
    //        ...
    //    ]
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        let parsedProducts = NSMutableArray()
        
        let countryInfoDao = RLMCountryInfoDAO()
        let currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDao)
        
        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        if let productsArrayJson = json.array {
            for productJson in productsArrayJson {
                parsedProducts.addObject(LGProductParser.productWithJSON(productJson, currencyHelper: currencyHelper, distanceType: distanceType))
            }
        }
        
        products = parsedProducts
        
    }
}
