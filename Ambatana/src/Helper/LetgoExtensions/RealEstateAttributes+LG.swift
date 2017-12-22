//
//  RealEstateAttributes+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension RealEstateAttributes {
    
    var generatedTitle: String {
        let propertyTypeString = propertyType?.shortLocalizedString.localizedUppercase
        let offerTypeString = offerType?.shortLocalizedString.capitalizedFirstLetterOnly
        var bedroomsString: String?
        if let bedroomsRawValue = bedrooms,
            let bedroomsValue = NumberOfBedrooms(rawValue: bedroomsRawValue)
        {
            bedroomsString = bedroomsValue.shortLocalizedString.localizedUppercase
        }
        var bathroomsString: String?
        if let bathroomsRawValue = bathrooms,
            let bathroomsValue = NumberOfBathrooms(rawValue: bathroomsRawValue),
            bathroomsValue != .zero
        {
            bathroomsString = bathroomsValue.shortLocalizedString.localizedUppercase
        }
        let attributes = [propertyTypeString, offerTypeString, bedroomsString, bathroomsString]
        return attributes.flatMap{ $0 }.joined(separator: " ")
    }
    
    var tags: [String] {
        var tags = [String]()
        if let propertyType = propertyType {
            tags.append(propertyType.shortLocalizedString.localizedUppercase)
        }
        if let offerType = offerType {
            tags.append(offerType.shortLocalizedString.capitalizedFirstLetterOnly)
        }
        if let bedrooms = bedrooms, let numBedrooms = NumberOfBedrooms(rawValue: bedrooms) {
            tags.append(numBedrooms.shortLocalizedString.localizedUppercase)
        }
        if let bathrooms = bathrooms, let numBathrooms = NumberOfBathrooms(rawValue: bathrooms) {
            let bathroomsTag = bathrooms == 0 ? LGLocalizedString.realEstateAttributeTagBathroom0 : numBathrooms.shortLocalizedString.localizedUppercase
            tags.append(bathroomsTag)
        }
        return tags
    }
    
}
