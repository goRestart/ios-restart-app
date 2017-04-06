//
//  ChatListing.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


public protocol ChatListing: BaseModel, Priceable {
    var name: String? { get }
    var status: ListingStatus { get }
    var image: File? { get }
    var price: ListingPrice { get }
    var currency: Currency { get }
}
