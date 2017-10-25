//
//  PostingDetailsViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

//
//  ListingViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class PostingDetailsViewModelSpec: BaseViewModelSpec {

        override func spec() {
        var sut: PostingDetailsViewModel!
            
        var locationManager: MockLocationManager!
        var tracker: MockTracker!
        var currencyHelper: CurrencyHelper!
            
        var postingDetailsStep: PostingDetailStep!
        var postListingState: PostListingState!
        var uploadedImageSource: EventParameterPictureSource!
        var postingSource: PostingSource!
        var postListingBasicInfo: PostListingBasicDetailViewModel!
        
        
        describe("PostingDetailsViewModelSpec") {
            
            func buildPostingDetailsViewModel() {
                sut = PostingDetailsViewModel(step: postingDetailsStep,
                                              postListingState: postListingState,
                                              uploadedImageSource: uploadedImageSource,
                                              postingSource: postingSource,
                                              postListingBasicInfo: postListingBasicInfo,
                                              tracker: tracker,
                                              currencyHelper: currencyHelper,
                                              locationManager: locationManager)

                sut.navigator = self
            }
            
            beforeEach {
                sut = nil
                locationManager = MockLocationManager()
                tracker = MockTracker()
                currencyHelper = Core.currencyHelper
            }
        }
    }
}


extension PostingDetailsViewModelSpec: PostListingNavigator {
    func cancelPostListing() { }
    func startDetails(postListingState: PostListingState,
                      uploadedImageSource: EventParameterPictureSource?,
                      postingSource: PostingSource,
                      postListingBasicInfo: PostListingBasicDetailViewModel) { }
    func nextPostingDetailStep(step: PostingDetailStep,
                               postListingState: PostListingState,
                               uploadedImageSource: EventParameterPictureSource?,
                               postingSource: PostingSource,
                               postListingBasicInfo: PostListingBasicDetailViewModel) { }
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo) { }
    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostListingTrackingInfo) { }
    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?) { }
}
