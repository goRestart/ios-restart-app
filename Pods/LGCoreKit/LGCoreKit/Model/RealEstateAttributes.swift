//
//  RealEstateAttributes.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 05/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public enum RealEstateOfferType: String {
    case rent = "rent"
    case sale = "sale"
}

public enum RealEstatePropertyType: String {
    case apartment = "apartment"
    case house = "house"
    case room = "room"
    case commercial = "commercial"
    case other = "other"
}

public struct RealEstateAttributes: Equatable {
    public let propertyType: RealEstatePropertyType?
    public let offerType: RealEstateOfferType?
    public let bedrooms: Int?
    public let bathrooms: Int?
    
    public init(propertyType: RealEstatePropertyType?, offerType: RealEstateOfferType?, bedrooms: Int?, bathrooms: Int?) {
        self.propertyType = propertyType
        self.offerType = offerType
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
    }
    public static func make(propertyType: String?, offerType: String?, bedrooms: Int?, bathrooms: Int?) -> RealEstateAttributes {
        let newPropertyType = RealEstatePropertyType(rawValue: propertyType ?? "")
        let offerType = RealEstateOfferType(rawValue: offerType ?? "")
        return self.init(propertyType: newPropertyType, offerType: offerType, bedrooms: bedrooms, bathrooms: bathrooms)
    }
    
    public static func emptyRealEstateAttributes() -> RealEstateAttributes {
        return RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: nil, bathrooms: nil)
    }
    
    public func updating(propertyType: RealEstatePropertyType? = nil,
                         offerType: RealEstateOfferType? = nil,
                         bedrooms: Int? = nil,
                         bathrooms: Int? = nil) -> RealEstateAttributes {
        
        return RealEstateAttributes(propertyType: propertyType ?? self.propertyType,
                                    offerType: offerType ?? self.offerType,
                                    bedrooms: bedrooms ?? self.bedrooms,
                                    bathrooms: bathrooms ?? self.bathrooms)
    }
}

public func ==(lhs: RealEstateAttributes, rhs: RealEstateAttributes) -> Bool {
    return lhs.propertyType == rhs.propertyType && lhs.offerType == rhs.offerType &&
        lhs.bedrooms == rhs.bedrooms && lhs.bathrooms == rhs.bathrooms
}

extension RealEstateAttributes : Decodable {
    
    /**
     Expects a json in the form:
     
     "realEstateAttributes": {
     "typeOfProperty": "room",
     "typeOfListing": "rent",
     "numberOfBedrooms": 1,
     "numberOfBathrooms": 2
     }
     */
    
    public static func decode(_ j: JSON) -> Decoded<RealEstateAttributes> {
        let result1 = curry(RealEstateAttributes.make)
        let result2 = result1 <^> j <|? "typeOfProperty"
        let result3 = result2 <*> j <|? "typeOfListing"
        let result4 = result3 <*> j <|? "numberOfBedrooms"
        let result  = result4 <*> j <|? "numberOfBathrooms"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "RealEstateAttributes parse error: \(error)")
        }
        return result
    }
}
