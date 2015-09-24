//
//  LGProductsFavouriteResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGProductsFavouriteResponse: ProductsFavouriteResponse, ResponseObjectSerializable {
    
    public var products: NSArray
    
    // MARK: - Lifecycle
    
    public init() {
        products = []
    }
    
    // MARK: - ResponseObjectSerializable

//    [
//        {...},
//        {...}
//      ...
//    ]
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        let parsedProducts = NSMutableArray()

        let countryCurrencyInfoDao = RLMCountryCurrencyInfoDAO()
        let currencyHelper = CurrencyHelper(countryCurrencyInfoDAO: countryCurrencyInfoDao)
        
        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        if let favouritesArrayJson = json.array {
            for favouriteJson in favouritesArrayJson {
                parsedProducts.addObject(LGProductParser.productWithJSON(favouriteJson, currencyHelper: currencyHelper, distanceType: distanceType))
            }
        }
        
        products = parsedProducts
        
    }
}
