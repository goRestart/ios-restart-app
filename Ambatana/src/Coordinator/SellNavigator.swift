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
    
    func startDetails(firstStep: PostingDetailStep,
                      postListingState: PostListingState,
                      uploadedImageSource: EventParameterMediaSource?,
                      uploadedVideoLength: TimeInterval?,
                      postingSource: PostingSource,
                      postListingBasicInfo: PostListingBasicDetailViewModel)
    func nextPostingDetailStep(step: PostingDetailStep,
                               postListingState: PostListingState,
                               uploadedImageSource: EventParameterMediaSource?,
                               uploadedVideoLength: TimeInterval?,
                               postingSource: PostingSource,
                               postListingBasicInfo: PostListingBasicDetailViewModel,
                               previousStepIsSummary: Bool)
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo)
    func closePostServicesAndPostInBackground(completion: @escaping (() -> Void))
    func closePostProductAndPostLater(params: ListingCreationParams,
                                      images: [UIImage]?,
                                      video: RecordedVideo?,
                                      trackingInfo: PostListingTrackingInfo)
    func closePostServicesAndPostLater(params: [ListingCreationParams],
                                       images: [UIImage]?,
                                       trackingInfo: PostListingTrackingInfo)
    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue,
                                            loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?)
    func showConfirmation(listingResult: ListingResult, trackingInfo: PostListingTrackingInfo, modalStyle: Bool)
    func showMultiListingPostConfirmation(listingResult: ListingsResult, trackingInfo: PostListingTrackingInfo, modalStyle: Bool)
    func openListingCreation(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo)
    func openListingsCreation(uploadedImageId: String,
                              multipostingSubtypes: [ServiceSubtype],
                              multipostingNewSubtypes: [String],
                              postListingState: PostListingState,
                              trackingInfo: PostListingTrackingInfo)
    func backToSummary()
    func openQueuedRequestsLoading(images: [UIImage], listingCreationParams: ListingCreationParams,
                                   imageSource: EventParameterMediaSource, postingSource: PostingSource)
}

protocol ListingPostedNavigator: class {
    func cancelListingPosted()
    func closeListingPosted(_ listing: Listing)
    func closeListingPostedAndOpenEdit(_ listing: Listing)
    func closeProductPostedAndOpenPost()
}

protocol MultiListingPostedNavigator: ListingPostedNavigator {
    func closeListingsPosted(_ listings: [Listing])
    func openEdit(forListing listing: Listing)
}

protocol BlockingPostingNavigator: class {
    func openCamera()
    func openPrice(listing: Listing, images: [UIImage], imageSource: EventParameterMediaSource, videoLength: TimeInterval?, postingSource: PostingSource)
    func openListingEditionLoading(listingParams: ListingEditionParams, listing: Listing, images: [UIImage], imageSource: EventParameterMediaSource, videoLength: TimeInterval?, postingSource: PostingSource)
    func openListingPosted(listing: Listing, images: [UIImage], imageSource: EventParameterMediaSource, videoLength: TimeInterval?, postingSource: PostingSource)
    func openCategoriesPickerWith(selectedCategory: ListingCategory?, delegate: PostingCategoriesPickDelegate)
    func closeCategoriesPicker()
    func closePosting()
    func postingSucceededWith(listing: Listing)
}

