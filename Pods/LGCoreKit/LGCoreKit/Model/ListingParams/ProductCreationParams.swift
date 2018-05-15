//
//  ProductCreationParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class ProductCreationParams: BaseListingParams {
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                images: [File],
                videos: [Video]) {
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
        return super.apiCreationEncode(userId: userId)
    }
}
