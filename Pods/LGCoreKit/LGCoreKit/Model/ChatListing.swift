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
    
    init(objectId: String?,
         name: String?,
         status: ListingStatus,
         image: File?,
         price: ListingPrice,
         currency: Currency)
}

extension ChatListing {
    func updating(listing: Listing) -> ChatListing {
        return type(of: self).init(objectId: listing.objectId,
                                   name: listing.name,
                                   status: listing.status,
                                   image: listing.images.first,
                                   price: listing.price,
                                   currency: listing.currency)
    }
    
    func updating(status: ListingStatus) -> ChatListing {
        return type(of: self).init(objectId: objectId,
                                   name: name,
                                   status: status,
                                   image: image,
                                   price: price,
                                   currency: currency)
    }
}
