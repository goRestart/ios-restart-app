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
                videos: [Video],
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
                   images: images,
                   videos: videos)
    }
    
    override func apiCreationEncode(userId: String) -> [String: Any] {
        
        var params: [String: Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = userId
        params["description"] = descr
        params["price"] = price.value
        params["priceFlag"] = price.priceFlag.rawValue
        params["currency"] = currency.code
        params["latitude"] = Float(location.latitude)
        params["longitude"] = Float(location.longitude)
        params["countryCode"] = postalAddress.countryCode
        params["city"] = postalAddress.city
        params["address"] = postalAddress.address
        params["zipCode"] = postalAddress.zipCode
        params["images"] = images.flatMap { $0.objectId }
        let paramsVideos: [[String: Any]] = videos.map { ["path": $0.path, "snapshot": $0.snapshot] }
        params["videos"] = paramsVideos

        var realEstateAttributesDict: [String: Any] = [:]
        realEstateAttributesDict["typeOfProperty"] = realEstateAttributes.propertyType?.rawValue
        realEstateAttributesDict["typeOfListing"] = realEstateAttributes.offerType?.rawValue
        realEstateAttributesDict["numberOfBedrooms"] = realEstateAttributes.bedrooms
        realEstateAttributesDict["numberOfBathrooms"] = realEstateAttributes.bathrooms
        realEstateAttributesDict["numberOfLivingRooms"] = realEstateAttributes.livingRooms
        realEstateAttributesDict["sizeSquareMeters"] = realEstateAttributes.sizeSquareMeters
        
        params["realEstateAttributes"] = realEstateAttributesDict
        
        return params
    }
}
