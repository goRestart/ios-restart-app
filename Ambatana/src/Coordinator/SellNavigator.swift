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
                      uploadedImageSource: EventParameterPictureSource?,
                      uploadedVideoLength: TimeInterval?,
                      postingSource: PostingSource,
                      postListingBasicInfo: PostListingBasicDetailViewModel)
    func nextPostingDetailStep(step: PostingDetailStep,
                               postListingState: PostListingState,
                               uploadedImageSource: EventParameterPictureSource?,
                               uploadedVideoLength: TimeInterval?,
                               postingSource: PostingSource,
                               postListingBasicInfo: PostListingBasicDetailViewModel,
                               previousStepIsSummary: Bool)
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo)
    func closePostServicesAndPostInBackground(params: [ListingCreationParams],
                                             trackingInfo: PostListingTrackingInfo)
    func closePostProductAndPostLater(params: ListingCreationParams,
                                      images: [UIImage]?,
                                      video: RecordedVideo?,
                                      trackingInfo: PostListingTrackingInfo)
    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue,
                                            loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?)
    func showConfirmation(listingResult: ListingResult, trackingInfo: PostListingTrackingInfo, modalStyle: Bool)
    func openListingCreation(listingParams: ListingCreationParams, trackingInfo: PostListingTrackingInfo)
    func backToSummary()
    func openQueuedRequestsLoading(images: [UIImage], listingCreationParams: ListingCreationParams,
                                   imageSource: EventParameterPictureSource, postingSource: PostingSource)
    func openRealEstateOnboarding(pages: [LGTutorialPage],
                                  origin: EventParameterTypePage,
                                  tutorialType: EventParameterTutorialType)
}
protocol ListingPostedNavigator: class {
    func cancelListingPosted()
    func closeListingPosted(_ listing: Listing)
    func closeListingPostedAndOpenEdit(_ listing: Listing)
    func closeProductPostedAndOpenPost()
}

protocol BlockingPostingNavigator: class {
    func openCamera()
    func openPrice(listing: Listing, images: [UIImage], imageSource: EventParameterPictureSource, videoLength: TimeInterval?, postingSource: PostingSource)
    func openListingEditionLoading(listingParams: ListingEditionParams, listing: Listing, images: [UIImage], imageSource: EventParameterPictureSource, videoLength: TimeInterval?, postingSource: PostingSource)
    func openListingPosted(listing: Listing, images: [UIImage], imageSource: EventParameterPictureSource, videoLength: TimeInterval?, postingSource: PostingSource)
    func openCategoriesPickerWith(selectedCategory: ListingCategory?, delegate: PostingCategoriesPickDelegate)
    func closeCategoriesPicker()
    func closePosting()
    func postingSucceededWith(listing: Listing)
}

