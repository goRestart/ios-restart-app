//
//  Car.swift
//  LGCoreKit
//
//  Created by Nestor on 20/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Foundation

public protocol Car: BaseListingModel, Priceable {

    var name: String? { get }
    var nameAuto: String? { get }
    var descr: String? { get }
    var price: ListingPrice { get }
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
   
    var carAttributes: CarAttributes { get }
}
