import LGCoreKit
import LGComponents

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
        if let bedrooms = bedrooms, let livingRooms = livingRooms {
            let numberOfRooms = NumberOfRooms(numberOfBedrooms: bedrooms, numberOfLivingRooms: livingRooms)
            roomsString = numberOfRooms.localizedString
        }
        
        var sizeSquareMetersString: String?
        if let size = sizeSquareMeters {
            sizeSquareMetersString = String(size).addingSquareMeterUnit
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
            attributes = [offerTypeString, propertyTypeString, roomsString, sizeSquareMetersString]
        }
        return attributes.compactMap{ $0 }.joined(separator: " ")
    }
    
    func generateTags(postingFlowType: PostingFlowType) ->  [String] {
        var tags = [String]()
        if let propertyType = propertyType {
            tags.append(propertyType.shortLocalizedString.localizedUppercase)
        }
        if let offerType = offerType {
            tags.append(offerType.shortLocalizedString.localizedCapitalized)
        }
        switch postingFlowType {
        case .standard:
            if let bedrooms = bedrooms, let numBedrooms = NumberOfBedrooms(rawValue: bedrooms) {
                tags.append(numBedrooms.shortLocalizedString.localizedUppercase)
            }
            if let bathrooms = bathrooms, let numBathrooms = NumberOfBathrooms(rawValue: bathrooms) {
                let bathroomsTag = bathrooms == 0 ? R.Strings.realEstateAttributeTagBathroom0.localizedUppercase : numBathrooms.shortLocalizedString.localizedUppercase
                tags.append(bathroomsTag)
            }
        case .turkish:
            if let bedrooms = bedrooms, let livingRooms = livingRooms {
                let numberOfRoomsTag = NumberOfRooms(numberOfBedrooms: bedrooms, numberOfLivingRooms: livingRooms).localizedString
                tags.append(numberOfRoomsTag)
            }
            if let sizeSquareMeters = sizeSquareMeters {
                let sizeSquareMetersTag = String(sizeSquareMeters).addingSquareMeterUnit
                tags.append(sizeSquareMetersTag)
            }
        }
        return tags
    }
}
