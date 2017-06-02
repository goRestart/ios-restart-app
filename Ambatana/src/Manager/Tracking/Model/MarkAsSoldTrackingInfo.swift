//
//  MarkAsSoldTrackingInfo.swift
//  LetGo
//
//  Created by Albert Hernández López on 02/06/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

struct MarkAsSoldTrackingInfo {
    let listingId: String?
    let price: ListingPrice
    let currency: Currency
    let categoryId: Int?
    let isBumpedUp: Bool
    let buyerId: String?
    let isFreePostingModeAllowed: Bool
    let typePage: EventParameterTypePage
    
    
    static func make(listing: Listing,
                     isBumpedUp: Bool,
                     buyerId: String?,
                     isFreePostingModeAllowed: Bool,
                     typePage: EventParameterTypePage) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: listing.objectId,
                                      price: listing.price,
                                      currency: listing.currency,
                                      categoryId: listing.category.rawValue,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: buyerId,
                                      isFreePostingModeAllowed: isFreePostingModeAllowed,
                                      typePage: typePage)
    }
    
    static func make(chatListing: ChatListing,
                     isBumpedUp: Bool,
                     buyerId: String?,
                     isFreePostingModeAllowed: Bool,
                     typePage: EventParameterTypePage) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: chatListing.objectId,
                                      price: chatListing.price,
                                      currency: chatListing.currency,
                                      categoryId: nil,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: buyerId,
                                      isFreePostingModeAllowed: isFreePostingModeAllowed,
                                      typePage: typePage)
    }
    
    func makeEventParameters() -> EventParameters {
        var params = EventParameters()
        params[.productId] = listingId
        params[.productPrice] = price.value
        params[.productCurrency] = currency.code
        params[.categoryId] = categoryId
        params[.typePage] = typePage.rawValue
        params[.freePosting] = eventParameterFreePostingWithPrice(isFreePostingModeAllowed, price: price).rawValue
        params[.isBumpedUp] = isBumpedUp
        return params
    }
    
    private func eventParameterFreePostingWithPrice(_ freePostingModeAllowed: Bool,
                                                    price: ListingPrice) -> EventParameterBoolean {
        guard freePostingModeAllowed else { return .notAvailable}
        return price.free ? .trueParameter : .falseParameter
    }
}
