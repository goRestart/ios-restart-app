//
//  CarCreationParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class CarCreationParams: BaseListingParams {
    
    public var carAttributes: CarAttributes
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                images: [File],
                videos: [Video],
                carAttributes: CarAttributes) {
        self.carAttributes = carAttributes
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
        
        var params = super.apiCreationEncode(userId: userId)
        params.removeValue(forKey: "price_flag")
        
        let carAttributesDict: [String: Any] = ["makeId": carAttributes.makeId ?? "",
                                                "modelId" : carAttributes.modelId ?? "",
                                                "year" : carAttributes.year ?? 0]
        params["carAttributes"] = carAttributesDict
        params["images"] = images.flatMap { $0.objectId }
        params["priceFlag"] = price.priceFlag.rawValue
        
        return params
    }
}
