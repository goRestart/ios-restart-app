//
//  LGProductResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 07/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGProductResponse: ProductResponse, ResponseObjectSerializable {
    
    public var product: Product
    
    // MARK: - Lifecycle
    
    public init() {
        product = LGProduct()
    }
    
    // MARK: - ResponseObjectSerializable
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        
        let countryInfoDao = RLMCountryInfoDAO()
        let currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDao)
        
        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        product = LGProductParser.productWithJSON(json, currencyHelper: currencyHelper, distanceType: distanceType)
        
    }
}
