//
//  LGProductSaveResponse.swift
//  Pods
//
//  Created by Dídac on 28/08/15.
//
//

import Alamofire
import SwiftyJSON

@objc public class LGProductSaveResponse: ProductResponse, ResponseObjectSerializable {
    
    public var product: Product
    
    // MARK: - Lifecycle
    
    public init() {
        product = LGProduct()
    }
    
    // MARK: - ResponseObjectSerializable
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)
        
        let countryCurrencyInfoDao = RLMCountryCurrencyInfoDAO()
        let currencyHelper = CurrencyHelper(countryCurrencyInfoDAO: countryCurrencyInfoDao)
        
        // since the response gives distance in the units passed per parameters,
        // we retrieve distance type the same way we do in productlistviewmodel
        var distanceType = DistanceType.Km
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
        
        product = LGProductParser.productWithJSON(json, currencyHelper: currencyHelper, distanceType: distanceType)
    }
}