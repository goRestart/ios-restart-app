//
//  MarkAsSoldTrackingInfo.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

struct MarkAsSoldTrackingInfo {
    private let listingId: String?
    private let price: ListingPrice
    private let currency: Currency
    private let categoryId: Int?
    private let isBumpedUp: EventParameterBoolean
    private let buyerId: String?
    private let typePage: EventParameterTypePage
    
    static func make(listing: Listing,
                     isBumpedUp: EventParameterBoolean,
                     typePage: EventParameterTypePage) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: listing.objectId,
                                      price: listing.price,
                                      currency: listing.currency,
                                      categoryId: listing.category.rawValue,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: nil,
                                      typePage: typePage)
    }
    
    static func make(chatListing: ChatListing,
                     isBumpedUp: EventParameterBoolean,
                     typePage: EventParameterTypePage) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: chatListing.objectId,
                                      price: chatListing.price,
                                      currency: chatListing.currency,
                                      categoryId: nil,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: nil,
                                      typePage: typePage)
    }
    
    func updating(buyerId: String?) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: listingId,
                                      price: price,
                                      currency: currency,
                                      categoryId: categoryId,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: buyerId,
                                      typePage: typePage)
    }
    
    func makeEventParameters() -> EventParameters {
        var params = EventParameters()
        params[.listingId] = listingId
        params[.listingPrice] = price.value
        params[.listingCurrency] = currency.code
        params[.categoryId] = categoryId
        params[.typePage] = typePage.rawValue
        params[.freePosting] = eventParameterFreePostingWithPrice(price: price).rawValue
        params[.isBumpedUp] = isBumpedUp.rawValue
        params[.userSoldTo] = buyerId
        return params
    }
    
    private func eventParameterFreePostingWithPrice(price: ListingPrice) -> EventParameterBoolean {
        return price.isFree ? .trueParameter : .falseParameter
    }
}
