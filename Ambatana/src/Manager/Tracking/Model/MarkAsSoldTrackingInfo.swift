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
    private let isFreePostingModeAllowed: Bool
    private let typePage: EventParameterTypePage
    
    static func make(listing: Listing,
                     isBumpedUp: EventParameterBoolean,
                     isFreePostingModeAllowed: Bool,
                     typePage: EventParameterTypePage) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: listing.objectId,
                                      price: listing.price,
                                      currency: listing.currency,
                                      categoryId: listing.category.rawValue,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: nil,
                                      isFreePostingModeAllowed: isFreePostingModeAllowed,
                                      typePage: typePage)
    }
    
    static func make(chatListing: ChatListing,
                     isBumpedUp: EventParameterBoolean,
                     isFreePostingModeAllowed: Bool,
                     typePage: EventParameterTypePage) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: chatListing.objectId,
                                      price: chatListing.price,
                                      currency: chatListing.currency,
                                      categoryId: nil,
                                      isBumpedUp: isBumpedUp,
                                      buyerId: nil,
                                      isFreePostingModeAllowed: isFreePostingModeAllowed,
                                      typePage: typePage)
    }
    
    func updating(buyerId: String?) -> MarkAsSoldTrackingInfo {
        return MarkAsSoldTrackingInfo(listingId: listingId,
                                      price: price,
                                      currency: currency,
                                      categoryId: categoryId,
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
        params[.isBumpedUp] = isBumpedUp.rawValue
        params[.userSoldTo] = buyerId
        return params
    }
    
    private func eventParameterFreePostingWithPrice(_ freePostingModeAllowed: Bool,
                                                    price: ListingPrice) -> EventParameterBoolean {
        guard freePostingModeAllowed else { return .notAvailable}
        return price.free ? .trueParameter : .falseParameter
    }
}
