//
//  PostingDetailsViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class PostingDetailsViewModelSpec: BaseViewModelSpec {
    
    var cancelPostingCalled: Bool = false
    var nextPostingDetailStepCalled: Bool = false
    var closePostProductAndPostInBackgroundCalled: Bool = false
    var closePostProductAndPostLaterCalled: Bool = false
    var openLoginIfNeededFromListingPosted: Bool = false
    
    override func spec() {
        var sut: PostingDetailsViewModel!
        
        var locationManager: MockLocationManager!
        var tracker: MockTracker!
        var currencyHelper: CurrencyHelper!
        var featureFlags: MockFeatureFlags!
        
        var postingDetailsStep: PostingDetailStep!
        var postListingState: PostListingState!
        var uploadedImageSource: EventParameterPictureSource! = .camera
        var postingSource: PostingSource! = .tabBar
        var postListingBasicInfo = PostListingBasicDetailViewModel()
        
        describe("PostingDetailsViewModelSpec") {
            func buildPostingDetailsViewModel() {
                sut = PostingDetailsViewModel(step: postingDetailsStep,
                                              postListingState: postListingState,
                                              uploadedImageSource: uploadedImageSource,
                                              postingSource: postingSource,
                                              postListingBasicInfo: postListingBasicInfo,
                                              tracker: tracker,
                                              currencyHelper: currencyHelper,
                                              locationManager: locationManager,
                                              featureFlags: featureFlags)
                sut.navigator = self
            }
            
            beforeEach {
                sut = nil
                locationManager = MockLocationManager()
                tracker = MockTracker()
                currencyHelper = Core.currencyHelper
                featureFlags = MockFeatureFlags()
                
                self.cancelPostingCalled = false
                self.nextPostingDetailStepCalled = false
                self.closePostProductAndPostInBackgroundCalled = false
                self.closePostProductAndPostLaterCalled = false
                self.openLoginIfNeededFromListingPosted = false
            }
            
            context("init with bathroom step") {
                beforeEach {
                    postingDetailsStep = .bathrooms
                    postListingState = PostListingState(postCategory: .realEstate)
                    buildPostingDetailsViewModel()
                }
                
                context("press next button") {
                    beforeEach {
                        sut.nextbuttonPressed()
                    }
                    it("call navigator to next detail step") {
                        expect(self.nextPostingDetailStepCalled) == true
                    }
                }
                context("press close button") {
                    beforeEach {
                        sut.closeButtonPressed()
                    }
                    it("post the item and close") {
                        expect(self.openLoginIfNeededFromListingPosted) == true
                    }
                }
                context("index 0 selected") {
                    beforeEach {
                        sut.indexSelected(index: 0)
                    }
                    it("move to next step") {
                        expect(self.nextPostingDetailStepCalled).toEventually(equal(true))
                    }
                }
                context("index 0 Deselected") {
                    beforeEach {
                        sut.indexDeselected(index: 0)
                    }
                    it("stay in the same screen") {
                        expect(self.nextPostingDetailStepCalled) == false
                    }
                }
            }
            
            context("init with summary step") {
                beforeEach {
                    postingDetailsStep = .summary
                    postListingState = PostListingState(postCategory: .realEstate)
                    buildPostingDetailsViewModel()
                }
                context("press next button") {
                    beforeEach {
                        sut.nextbuttonPressed()
                    }
                    it("posts the item and close") {
                        expect(self.openLoginIfNeededFromListingPosted) == true
                    }
                    it("calls navigator to next detail step") {
                        expect(self.nextPostingDetailStepCalled) == false
                    }
                }
                context("press close button") {
                    beforeEach {
                        sut.closeButtonPressed()
                    }
                    it("posts the item and close") {
                        expect(self.openLoginIfNeededFromListingPosted) == true
                    }
                }
                context("index 0 selected") {
                    beforeEach {
                        sut.indexSelected(index: 0)
                    }
                    it("does not move to next step") {
                        expect(self.nextPostingDetailStepCalled).toEventually(equal(false))
                    }
                }
                context("index 0 Deselected") {
                    beforeEach {
                        sut.indexDeselected(index: 0)
                    }
                    it("stays in the same screen") {
                        expect(self.nextPostingDetailStepCalled) == false
                    }
                }
            }
            context("init with price step") {
                beforeEach {
                    postingDetailsStep = .price
                    postListingState = PostListingState(postCategory: .realEstate)
                    buildPostingDetailsViewModel()
                }
                
                context("press next button") {
                    beforeEach {
                        sut.nextbuttonPressed()
                    }
                    it("calls navigator to next detail step") {
                        expect(self.nextPostingDetailStepCalled) == true
                    }
                    it("calls navigator to next detail step") {
                        expect(self.openLoginIfNeededFromListingPosted) == false
                    }
                }
                context("press close button") {
                    beforeEach {
                        sut.closeButtonPressed()
                    }
                    it("post the item and close") {
                        expect(self.openLoginIfNeededFromListingPosted) == true
                    }
                }
                context("index 0 selected") {
                    beforeEach {
                        sut.indexSelected(index: 0)
                    }
                    it("does not move to next step because there is no index") {
                        expect(self.nextPostingDetailStepCalled).toEventually(equal(false))
                    }
                }
                context("index 0 Deselected") {
                    beforeEach {
                        sut.indexDeselected(index: 0)
                    }
                    it("stays in the same screen") {
                        expect(self.nextPostingDetailStepCalled) == false
                    }
                }
            }
        }
    }
}


extension PostingDetailsViewModelSpec: PostListingNavigator {
    func cancelPostListing() {
        cancelPostingCalled = true
        
    }
    func startDetails(postListingState: PostListingState,
                      uploadedImageSource: EventParameterPictureSource?,
                      postingSource: PostingSource,
                      postListingBasicInfo: PostListingBasicDetailViewModel) { }
    func nextPostingDetailStep(step: PostingDetailStep,
                               postListingState: PostListingState,
                               uploadedImageSource: EventParameterPictureSource?,
                               postingSource: PostingSource,
                               postListingBasicInfo: PostListingBasicDetailViewModel) {
        nextPostingDetailStepCalled = true
    }
    func closePostProductAndPostInBackground(params: ListingCreationParams,
                                             trackingInfo: PostListingTrackingInfo) {
        closePostProductAndPostInBackgroundCalled = true
    }
    func closePostProductAndPostLater(params: ListingCreationParams, images: [UIImage],
                                      trackingInfo: PostListingTrackingInfo) {
        closePostProductAndPostLaterCalled = true
    }
    func openLoginIfNeededFromListingPosted(from: EventParameterLoginSourceValue, loggedInAction: @escaping (() -> Void), cancelAction: (() -> Void)?) {
        openLoginIfNeededFromListingPosted = true
    }
}
