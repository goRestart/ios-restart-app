//
//  PostProductDetailViewModelSpec.swift
//  LetGo
//
//  Created by Dídac on 12/07/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class PostProductDetailViewModelSpec: BaseViewModelSpec {

    override func spec() {
        describe("PostProductDetailViewModel") {
            var sut: PostProductDetailViewModel!

            beforeEach {
                sut = PostProductDetailViewModel()
            }

            context("price creation") {
                context("free") {
                    beforeEach {
                        sut.isFree.value = true
                        sut.price.value = ""
                    }
                    it ("productPrice is free") {
                        expect(sut.productPrice) == ListingPrice.free
                    }
                }
                context("negotiable") {
                    beforeEach {
                        sut.isFree.value = false
                        sut.price.value = "0"
                    }
                    it ("productPrice is negotiable") {
                        expect(sut.productPrice) == ListingPrice.negotiable(0.0)
                    }
                }
                context("has price") {
                    beforeEach {
                        sut.isFree.value = false
                        sut.price.value = "10"
                    }
                    it ("productPrice is normal") {
                        expect(sut.productPrice) == ListingPrice.normal(10.0)
                    }
                }
            }
            context("listing title creation") {
                context("title not specified") {
                    beforeEach {
                        sut.title.value = ""
                    }
                    it ("productTitle is nil") {
                        expect(sut.productTitle).to(beNil())
                    }
                }
                context("title specified") {
                    beforeEach {
                        sut.title.value = "cool thing"
                    }
                    it ("productTitle has a value") {
                        expect(sut.productTitle) == "cool thing"
                    }
                }
            }
            context("listing description creation") {
                context("description not specified") {
                    beforeEach {
                        sut.description.value = ""
                    }
                    it ("productDescription is nil") {
                        expect(sut.productDescription).to(beNil())
                    }
                }
                context("description specified") {
                    beforeEach {
                        sut.description.value = "this cool thing does stuff"
                    }
                    it ("productDescription has a value") {
                        expect(sut.productDescription) == "this cool thing does stuff"
                    }
                }
            }
        }
    }
}
