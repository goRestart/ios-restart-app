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
                        sut = listingPrice.stringValue(currency: currency)
                    }
                    it("Free") {
                        expect(sut) == R.Strings.productFreePrice
                    }
                }
                context("listingPrice normal without price") {
                    beforeEach {
                        listingPrice = .normal(0)
                        sut = listingPrice.stringValue(currency: currency)
                        
                    }
                    it("is negotiable") {
                        expect(sut) == R.Strings.productNegotiablePrice
                    }
                }
            }            

        }
        
        describe("allowFreeFilters") {
            var sut: LetGoGodMode.EventParameterBoolean!
            context("listingPrice free") {
                beforeEach {
                    listingPrice = .free
                    sut = listingPrice.allowFreeFilters()
                }
                it("true value") {
                    expect(sut) == .trueParameter
                }
            }
            
            context("listingPrice NOT free") {
                beforeEach {
                    listingPrice = .normal(1.0)
                    sut = listingPrice.allowFreeFilters()
                }
                it("true value") {
                    expect(sut) == .falseParameter
                }
            }
        }
    }
}
