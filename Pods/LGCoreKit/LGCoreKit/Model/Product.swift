//
//  PartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//


//Remove all setters and change by a factory method if required
public protocol Product: BaseListingModel, Priceable {
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
}
