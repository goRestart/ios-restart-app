//
//  LGProductsFavouriteResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 02/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

public class LGProductsFavouriteResponse: ProductsFavouriteResponse, ResponseObjectSerializable {
    
    public var products: [Product]
    
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
        var parsedProducts: [Product] = []

        guard let countryInfoDao = RLMCountryInfoDAO() else {
            return nil
        }
        
        let currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDao)
        
        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        if let favouritesArrayJson = json.array {
            for favouriteJson in favouritesArrayJson {
                parsedProducts.append(LGProductParser.productWithJSON(favouriteJson, currencyHelper: currencyHelper, distanceType: distanceType))
            }
        }
        
        products = parsedProducts
    }
}
