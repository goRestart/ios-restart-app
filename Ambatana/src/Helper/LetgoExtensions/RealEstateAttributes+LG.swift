//
//  RealEstateAttributes+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension RealEstateAttributes {
    
    private var sortedAttributesForGeneratedTitle: [String] {
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
        return attributes.flatMap{ $0 }
    }
    
    var generatedTitle: String {
        let separator = " "
        let title = sortedAttributesForGeneratedTitle.joined(separator: separator)
        return title
    }
    
    var tags: [String] {
        return sortedAttributesForGeneratedTitle
    }
    
}
