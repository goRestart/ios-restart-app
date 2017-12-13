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
        let separator = " "
        var title: String = ""
        
        let propertyTypeString = propertyType?.shortLocalizedString.localizedUppercase
        let offerTypeString = offerType?.shortLocalizedString.localizedUppercase
        var bedroomsString: String? = nil
        if let bedroomsRawValue = bedrooms, let bedroomsValue = NumberOfBedrooms(rawValue: bedroomsRawValue) {
            bedroomsString = bedroomsValue.shortLocalizedString.localizedUppercase
        }
        var bathroomsString: String? = nil
        if let bathroomsRawValue = bathrooms,
            let bathroomsValue = NumberOfBathrooms(rawValue: bathroomsRawValue),
            bathroomsValue != .zero {
             bathroomsString = bathroomsValue.shortLocalizedString.localizedUppercase
        }
        title = [propertyTypeString, offerTypeString, bedroomsString, bathroomsString].flatMap{ $0 }.joined(separator: separator)
        
        return title
    }
}
