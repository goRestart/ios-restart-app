//
//  RealEstateCreationParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 18/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class RealEstateCreationParams: BaseListingParams {
    
    public var realEstateAttributes: RealEstateAttributes
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                images: [File],
                realEstateAttributes: RealEstateAttributes) {
        self.realEstateAttributes = realEstateAttributes
        super.init(name: name,
                   description: description,
                   price: price,
                   category: category,
                   currency: currency,
                   location: location,
                   postalAddress: postalAddress,
                   languageCode: Locale.current.identifier,
                   images: images)
    }
    
    override func apiCreationEncode(userId: String) -> [String: Any] {
        
        var params = super.apiCreationEncode(userId: userId)
        
        var realEstateAttributesDict: [String: Any] = [:]
        realEstateAttributesDict["typeOfProperty"] = realEstateAttributes.propertyType
        realEstateAttributesDict["typeOfListing"] = realEstateAttributes.offerType
        realEstateAttributesDict["numberOfBedrooms"] = realEstateAttributes.bedrooms
        realEstateAttributesDict["numberOfBathrooms"] = realEstateAttributes.bathrooms
        
        params["attributes"] = realEstateAttributesDict
        
        return params
    }
}
