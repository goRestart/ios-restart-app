//
//  BaseListingParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class BaseListingParams {
    public var name: String?
    public var descr: String?
    public var price: ListingPrice
    public var category: ListingCategory
    public var currency: Currency
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    public var images: [File]
    public var videos: [Video]
    var languageCode: String
    
    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                languageCode: String,
                images: [File],
                videos: [Video]) {
        self.name = name
        self.descr = description
        self.price = price
        self.category = category
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        self.languageCode = languageCode
        self.images = images
        self.videos = videos
    }
    
    func apiCreationEncode(userId: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = userId
        params["description"] = descr
        params["price"] = price.value
        params["price_flag"] = price.priceFlag.rawValue
        params["currency"] = currency.code
        params["latitude"] = location.latitude
        params["longitude"] = location.longitude
        params["countryCode"] = postalAddress.countryCode
        params["city"] = postalAddress.city
        params["address"] = postalAddress.address
        params["zipCode"] = postalAddress.zipCode
        
        let tokensString = images.flatMap{$0.objectId}.map{"\"" + $0 + "\""}.joined(separator: ",")
        params["images"] = "[" + tokensString + "]"

        let paramsVideos: [[String: Any]] = videos.map { ["path": $0.path, "snapshot": $0.snapshot] }
        params["videos"] = paramsVideos

        return params
    }
}
