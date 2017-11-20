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
    var generateRealEstateName: String {
        let separator = " "
        var realEstateTitle: String = ""
        
        if let propertyType = propertyType {
            realEstateTitle = propertyType.shortLocalizedString.localizedUppercase
        }
        if let offerType = offerType {
            let separator = realEstateTitle.isEmpty ? "" : separator
            realEstateTitle += separator + offerType.shortLocalizedString.localizedUppercase
        }
        if let bedrooms = bedrooms, let numberOfBedrooms = NumberOfBedrooms(rawValue: bedrooms) {
            let separator = realEstateTitle.isEmpty ? "" : separator
            realEstateTitle += separator + numberOfBedrooms.shortLocalizedString.localizedUppercase
        }
        if let bathrooms = bathrooms, let numberOfBathrooms = NumberOfBathrooms(rawValue: bathrooms) {
            let separator = realEstateTitle.isEmpty ? "" : separator
            realEstateTitle += separator + numberOfBathrooms.shortLocalizedString.localizedUppercase
        }
        return realEstateTitle
    }
}
