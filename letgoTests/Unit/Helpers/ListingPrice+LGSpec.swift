//
//  ListingPrice+LGSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 06/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble

class ListingPriceLGSpec: QuickSpec {
    override func spec() {
        var listingPrice: ListingPrice!
        var currency: Currency!
        var sut: String!
        
        describe("ListingPrice + LG methods") {
            beforeEach {
                currency = Currency.makeMock()
            }
            context("stringValue with currency and free enabled") {
                context("listingPrice free") {
                    beforeEach {
                        listingPrice = .free
                        sut = listingPrice.stringValue(currency: currency, isFreeEnabled: true)
                    }
                    it("Free") {
                        expect(sut) == LGLocalizedString.productFreePrice
                    }
                }
                context("listingPrice negotiable without price") {
                    beforeEach {
                        listingPrice = .negotiable(0)
                        sut = listingPrice.stringValue(currency: currency, isFreeEnabled: true)
                        
                    }
                    it("is negotiable") {
                        expect(sut) == LGLocalizedString.productNegotiablePrice
                    }
                }
            }
            context("stringValue with currency and free disabled") {
                context("listingPrice free") {
                    beforeEach {
                        listingPrice = .free
                        sut = listingPrice.stringValue(currency: currency, isFreeEnabled: false)
                    }
                    it("is negotiable") {
                        expect(sut) == LGLocalizedString.productNegotiablePrice
                    }
                }
            }

        }
    }
}
