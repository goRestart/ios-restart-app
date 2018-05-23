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
import LGComponents

class ListingPriceLGSpec: QuickSpec {
    override func spec() {
        var listingPrice: ListingPrice!
        var currency: Currency!
        
        
        describe("ListingPrice + LG methods") {
            var sut: String!
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
                        expect(sut) == R.Strings.productFreePrice
                    }
                }
                context("listingPrice normal without price") {
                    beforeEach {
                        listingPrice = .normal(0)
                        sut = listingPrice.stringValue(currency: currency, isFreeEnabled: true)
                        
                    }
                    it("is negotiable") {
                        expect(sut) == R.Strings.productNegotiablePrice
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
                        expect(sut) == R.Strings.productNegotiablePrice
                    }
                }
            }

        }
        
        describe("allowFreeFilters") {
            var sut:EventParameterBoolean!
            context("listingPrice free") {
                beforeEach {
                    listingPrice = .free
                    sut = listingPrice.allowFreeFilters(freePostingModeAllowed: true)
                }
                it("true value") {
                    expect(sut) == .trueParameter
                }
            }
            
            context("listingPrice NOT free") {
                beforeEach {
                    listingPrice = .normal(1.0)
                    sut = listingPrice.allowFreeFilters(freePostingModeAllowed: true)
                }
                it("true value") {
                    expect(sut) == .falseParameter
                }
            }
            
            context("listingPrice NOT available") {
                beforeEach {
                    listingPrice = .normal(1.0)
                    sut = listingPrice.allowFreeFilters(freePostingModeAllowed: false)
                }
                it("true value") {
                    expect(sut) == .notAvailable
                }
            }
        }
    }
}
