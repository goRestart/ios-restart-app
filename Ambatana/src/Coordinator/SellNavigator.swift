//
//  SellNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation

enum PostingDetailStep {
    case price
    case propertyType
    case offerType
    case bedrooms
    case bathrooms
    case summary
    
    var title: String {
        switch self {
        case .price:
            return LGLocalizedString.realEstatePriceTitle
        case .propertyType:
            return LGLocalizedString.realEstateTypePropertyTitle
        case .offerType:
            return LGLocalizedString.realEstateOfferTypeTitle
        case .bedrooms:
            return LGLocalizedString.realEstateBedroomsTitle
        case .bathrooms:
            return LGLocalizedString.realEstateBathroomsTitle
        case .summary:
            return LGLocalizedString.realEstateSummaryTitle
        }
    }
}

protocol PostListingNavigator: class {
    func cancelPostListing()
    func startDetails()
    func nextPostingDetailStep(step: PostingDetailStep)
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo)
    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostListingTrackingInfo)
    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?)
}

protocol ListingPostedNavigator: class {
    func cancelListingPosted()
    func closeListingPosted(_ listing: Listing)
    func closeListingPostedAndOpenEdit(_ listing: Listing)
    func closeProductPostedAndOpenPost()
}
