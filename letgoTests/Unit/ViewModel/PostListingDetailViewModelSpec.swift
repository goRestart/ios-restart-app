//
//  PostListingDetailViewModelSpec.swift
//  LetGo
//
//  Created by Dídac on 12/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class PostListingDetailViewModelSpec: BaseViewModelSpec {

    override func spec() {
        describe("PostListingDetailViewModel") {
            var sut: PostListingDetailViewModel!

            beforeEach {
                sut = PostListingDetailViewModel()
            }

            context("price creation") {
                context("free") {
                    beforeEach {
                        sut.isFree.value = true
                        sut.price.value = ""
                    }
                    it ("listingPrice is free") {
                        expect(sut.listingPrice) == ListingPrice.free
                    }
                }
                context("negotiable") {
                    beforeEach {
                        sut.isFree.value = false
                        sut.price.value = "0"
                    }
                    it ("listingPrice is negotiable") {
                        expect(sut.listingPrice) == ListingPrice.negotiable(0.0)
                    }
                }
                context("has price") {
                    beforeEach {
                        sut.isFree.value = false
                        sut.price.value = "10"
                    }
                    it ("listingPrice is normal") {
                        expect(sut.listingPrice) == ListingPrice.normal(10.0)
                    }
                }
            }
            context("listing title creation") {
                context("title not specified") {
                    beforeEach {
                        sut.title.value = ""
                    }
                    it ("listingTitle is nil") {
                        expect(sut.listingTitle).to(beNil())
                    }
                }
                context("title specified") {
                    beforeEach {
                        sut.title.value = "cool thing"
                    }
                    it ("listingTitle has a value") {
                        expect(sut.listingTitle) == "cool thing"
                    }
                }
            }
            context("listing description creation") {
                context("description not specified") {
                    beforeEach {
                        sut.description.value = ""
                    }
                    it ("listingDescription is nil") {
                        expect(sut.listingDescription).to(beNil())
                    }
                }
                context("description specified") {
                    beforeEach {
                        sut.description.value = "this cool thing does stuff"
                    }
                    it ("listingDescription has a value") {
                        expect(sut.listingDescription) == "this cool thing does stuff"
                    }
                }
            }
        }
    }
}
