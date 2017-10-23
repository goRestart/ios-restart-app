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
    func startDetails(postListingState: PostListingState,
                      uploadedImageSource: EventParameterPictureSource?,
                      postingSource: PostingSource,
                      postListingBasicInfo: PostListingBasicDetailViewModel)
    func nextPostingDetailStep(step: PostingDetailStep,
                               postListingState: PostListingState,
                               uploadedImageSource: EventParameterPictureSource?,
                               postingSource: PostingSource,
                               postListingBasicInfo: PostListingBasicDetailViewModel)
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
