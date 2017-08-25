//
//  SellNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation

protocol PostListingNavigator: class {
    func cancelPostListing()
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo)
    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostListingTrackingInfo)
    func openLoginIfNeededFromProductPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?)
}

protocol ProductPostedNavigator: class {
    func cancelProductPosted()
    func closeProductPosted(_ listing: Listing)
    func closeProductPostedAndOpenEdit(_ listing: Listing)
    func closeProductPostedAndOpenPost()
}
