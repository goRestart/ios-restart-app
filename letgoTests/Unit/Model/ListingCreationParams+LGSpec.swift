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
        
        var place = Place.makeMock()
        place.postalAddress = PostalAddress.makeMock()
        place.location = LGLocationCoordinates2D.makeMock()
        let location = LGLocationCoordinates2D.makeMock()
        let postalAddress = PostalAddress.makeMock()
        var postListingState: PostListingState!
        
        var sut : ListingCreationParams!
        describe("make params") {
            describe("price") {
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
            }
        }
        fdescribe("location") {
            beforeEach {
                postListingState = PostListingState(postCategory: .realEstate)
                postListingState = postListingState.updatingStepToUploadingImages()
                postListingState = postListingState.updatingToSuccessUpload(uploadedImages: [MockFile].makeMocks())
                postListingState = postListingState.updatingAfterUploadingSuccess()
                postListingState = postListingState.updating(price: .free)
            }
            context("location edited during posting") {
                beforeEach {
                    postListingState = postListingState.updating(place: place)
                    sut = ListingCreationParams.make(title: "title",
                                                     description: "description",
                                                     currency: Currency.makeMock(),
                                                     location: location,
                                                     postalAddress: postalAddress,
                                                     postListingState: postListingState)
                }
                it("saves location from place") {
                    expect(sut.location).to(equal(postListingState.place?.location))
                }
                it("saves postalAddress from place") {
                    expect(sut.postalAddress) == postListingState.place?.postalAddress
                    
                }
            }
            context("location not edited during posting") {
                beforeEach {
                    sut = ListingCreationParams.make(title: "title",
                                                     description: "description",
                                                     currency: Currency.makeMock(),
                                                     location: location,
                                                     postalAddress: postalAddress,
                                                     postListingState: postListingState)
                }
                it("saves location value") {
                    expect(sut.location).to(equal(location))
                }
                it("saves postalAddress from postalAddress") {
                    expect(sut.postalAddress) == postalAddress
                }
            }
        }
    }
}
