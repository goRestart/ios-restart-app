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
        
        let propertyTypeString = propertyType?.shortLocalizedString.localizedUppercase
        let offerTypeString = offerType?.shortLocalizedString.localizedUppercase
        var bedroomsString: String? = nil
        if let bedroomsRawValue = bedrooms, let bedroomsValue = NumberOfBedrooms(rawValue: bedroomsRawValue) {
            bedroomsString = bedroomsValue.shortLocalizedString.localizedUppercase
        }
        var bathroomsString: String? = nil
        if let bathroomsRawValue = bathrooms, let bathroomsValue = NumberOfBathrooms(rawValue: bathroomsRawValue) {
             bathroomsString = bathroomsValue.shortLocalizedString.localizedUppercase
        }
        realEstateTitle = [propertyTypeString, offerTypeString, bedroomsString, bathroomsString].flatMap{ $0 }.joined(separator: separator)
        
        return realEstateTitle
    }
}
