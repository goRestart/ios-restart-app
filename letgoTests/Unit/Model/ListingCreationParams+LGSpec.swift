//
//  ListingCreationParamsSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 07/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Quick
import Nimble
import Argo
import LGCoreKit
@testable import LetGoGodMode


class ListingCreationParamsLGSpec: QuickSpec {
    
    override func spec() {
        
        var sut : ListingCreationParams!
        describe("make params") {
            context("make with price") {
                beforeEach {
                    var postListingState = PostListingState(postCategory: .motorsAndAccessories)
                    postListingState = postListingState.updatingStepToUploadingImages()
                    postListingState = postListingState.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                    postListingState = postListingState.updatingAfterUploadingSuccess()
                    postListingState = postListingState.updating(price: .normal(100))
                    sut = ListingCreationParams.make(title: "title",
                                                     description: "description",
                                                     currency: Currency.makeMock(),
                                                     location: LGLocationCoordinates2D.makeMock(),
                                                     postalAddress: PostalAddress.makeMock(),
                                                     postListingState: postListingState)
                }
                it("price is normal 100") {
                    expect(sut.price).to(equal(.normal(100)))
                }
            }
            context("make with negotiable") {
                beforeEach {
                    var postListingState = PostListingState(postCategory: .motorsAndAccessories)
                    postListingState = postListingState.updatingStepToUploadingImages()
                    postListingState = postListingState.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                    postListingState = postListingState.updatingAfterUploadingSuccess()
                    postListingState = postListingState.updating(price: .negotiable(0))
                    sut = ListingCreationParams.make(title: "title",
                                                     description: "description",
                                                     currency: Currency.makeMock(),
                                                     location: LGLocationCoordinates2D.makeMock(),
                                                     postalAddress: PostalAddress.makeMock(),
                                                     postListingState: postListingState)
                }
                it("price is negotiable zero") {
                    expect(sut.price).to(equal(.negotiable(0)))
                }
            }
            context("make with free") {
                beforeEach {
                    var postListingState = PostListingState(postCategory: .motorsAndAccessories)
                    postListingState = postListingState.updatingStepToUploadingImages()
                    postListingState = postListingState.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                    postListingState = postListingState.updatingAfterUploadingSuccess()
                    postListingState = postListingState.updating(price: .free)
                    sut = ListingCreationParams.make(title: "title",
                                                     description: "description",
                                                     currency: Currency.makeMock(),
                                                     location: LGLocationCoordinates2D.makeMock(),
                                                     postalAddress: PostalAddress.makeMock(),
                                                     postListingState: postListingState)
                }
                it("price is negotiable zero") {
                    expect(sut.price).to(equal(ListingPrice.free))
                }
            }
            context("make with no price") {
                beforeEach {
                    var postListingState = PostListingState(postCategory: .motorsAndAccessories)
                    postListingState = postListingState.updatingStepToUploadingImages()
                    postListingState = postListingState.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                    postListingState = postListingState.updatingAfterUploadingSuccess()
                    sut = ListingCreationParams.make(title: "title",
                                                     description: "description",
                                                     currency: Currency.makeMock(),
                                                     location: LGLocationCoordinates2D.makeMock(),
                                                     postalAddress: PostalAddress.makeMock(),
                                                     postListingState: postListingState)
                }
                it("price is negotiable zero") {
                    expect(sut.price).to(equal(ListingPrice.negotiable(0)))
                }
            }
        }
    }
}
