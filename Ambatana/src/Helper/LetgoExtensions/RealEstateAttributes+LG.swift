//
//  RealEstateAttributes+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension RealEstateAttributes {
    
    func generateTitle(postingFlowType: PostingFlowType) -> String {
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
        
        var roomsString: String?
        if let _ = bedrooms, let _ = livingRooms {
            let numberOfRooms = NumberOfRooms(bedrooms: bedrooms, livingRooms: livingRooms)
            roomsString = numberOfRooms.localizedString
        }
        
        var sizeSquareMetersString: String?
        if let size = sizeSquareMeters {
            sizeSquareMetersString = String(size) + Constants.sizeSquareMetersUnit
        }
        
        if let bathroomsRawValue = bathrooms,
            let bathroomsValue = NumberOfBathrooms(rawValue: bathroomsRawValue),
            bathroomsValue != .zero
        {
            bathroomsString = bathroomsValue.shortLocalizedString.localizedUppercase
        }
        
        let attributes: [String?]
        if postingFlowType == .standard {
            attributes = [propertyTypeString, offerTypeString, bedroomsString, bathroomsString]
        } else {
            attributes = [propertyTypeString, offerTypeString, roomsString, sizeSquareMetersString]
        }
        return attributes.flatMap{ $0 }.joined(separator: " ")
    }
    
    func generateTags() ->  [String] {
        var tags = [String]()
        if let propertyType = propertyType {
            tags.append(propertyType.shortLocalizedString.localizedUppercase)
        }
        if let offerType = offerType {
            tags.append(offerType.shortLocalizedString.localizedCapitalized)
        }
        if let bedrooms = bedrooms, let numBedrooms = NumberOfBedrooms(rawValue: bedrooms) {
            tags.append(numBedrooms.shortLocalizedString.localizedUppercase)
        }
        if let bathrooms = bathrooms, let numBathrooms = NumberOfBathrooms(rawValue: bathrooms) {
            let bathroomsTag = bathrooms == 0 ? LGLocalizedString.realEstateAttributeTagBathroom0.localizedUppercase : numBathrooms.shortLocalizedString.localizedUppercase
            tags.append(bathroomsTag)
        }
        return tags
    }
}
