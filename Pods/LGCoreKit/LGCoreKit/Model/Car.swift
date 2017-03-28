//
//  Car.swift
//  LGCoreKit
//
//  Created by Nestor on 20/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol Car: BaseModel, Priceable {
    var name: String? { get }
    var nameAuto: String? { get }
    var descr: String? { get }
    var price: ProductPrice { get }
    var currency: Currency { get }
    
    var location: LGLocationCoordinates2D { get }
    var postalAddress: PostalAddress { get }
    
    var languageCode: String? { get }
    
    var category: ListingCategory { get }
    var status: ListingStatus { get }
    
    var thumbnail: File? { get }
    var thumbnailSize: LGSize? { get }
    var images: [File] { get }          // Default value []
    
    var user: UserListing { get }
    
    var updatedAt : Date? { get }
    var createdAt : Date? { get }
    
    var featured: Bool? { get }
    
    var favorite: Bool { get }          // Default value false
}

extension Car {
    func encode() -> [String: Any] {
        var params: [String: Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = user.objectId
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
        
        return params
    }
}
