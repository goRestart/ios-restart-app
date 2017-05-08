//
//  SellNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 20/06/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Foundation

protocol PostProductNavigator: class {
    func cancelPostProduct()
    func closePostProductAndPostInBackground(params: ListingCreationParams, showConfirmation: Bool,
                                             trackingInfo: PostProductTrackingInfo)
    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostProductTrackingInfo)
    func openLoginIfNeededFromProductPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?)
}

protocol ProductPostedNavigator: class {
    func cancelProductPosted()
    func closeProductPosted(_ listing: Listing)
    func closeProductPostedAndOpenEdit(_ listing: Listing)
    func closeProductPostedAndOpenPost()
}
