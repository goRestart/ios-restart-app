//
//  RealEstateAttributes+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

/*
 public let propertyType: LGCoreKit.RealEstatePropertyType?
 
 public let offerType: LGCoreKit.RealEstateOfferType?
 
 public let bedrooms: Int?
 
 public let bathrooms: Float?
 */

extension RealEstateAttributes {
    func generateRealEstateName() -> String {
        let separator = " "
        var realEstateTitle: String = ""
        
        if let propertyType = propertyType {
            realEstateTitle = propertyType.shortLocalizedString
        }
        if let offerType = offerType {
            let separator = realEstateTitle.isEmpty ? "" : separator
            realEstateTitle += separator + offerType.localizedString
        }
        if let bedrooms = bedrooms, let numberOfBedrooms = NumberOfBedrooms(rawValue: bedrooms) {
            let separator = realEstateTitle.isEmpty ? "" : separator
            realEstateTitle += separator + numberOfBedrooms.localizedString
        }
        if let bathrooms = bathrooms, let numberOfBathrooms = NumberOfBathrooms(rawValue: bathrooms) {
            let separator = realEstateTitle.isEmpty ? "" : separator
            realEstateTitle += separator + numberOfBathrooms.localizedString
        }
        return realEstateTitle
    }
}
