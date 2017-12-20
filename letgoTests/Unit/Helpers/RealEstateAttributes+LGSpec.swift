//
//  RealEstateAttributes+LGSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 20/11/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import Quick
import Nimble
import LGCoreKit

class RealEstateAttributesLGSpec: QuickSpec {
    override func spec() {
        var realEstateAttributes: RealEstateAttributes!
        var sut: String!
        
        describe("Generate real estate posting") {
            context("with no data on attributes") {
                beforeEach {
                    realEstateAttributes = RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: nil, bathrooms: nil)
                    sut = realEstateAttributes.generatedTitle
                }
                it ("returns empty title") {
                    expect(sut) == ""
                }
                context("attributes with property and offertype") {
                    beforeEach {
                        realEstateAttributes = RealEstateAttributes(propertyType: .other, offerType: .rent, bedrooms: nil, bathrooms: nil)
                        sut = realEstateAttributes.generatedTitle
                    }
                    it ("result should equal: OTHER For rent") {
                        expect(sut) == "OTHER For rent"
                    }
                }
                context("attributes with bedrooms") {
                    beforeEach {
                        realEstateAttributes = RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: 3, bathrooms: nil)
                        sut = realEstateAttributes.generatedTitle
                    }
                    it ("result should equal: 3BR") {
                        expect(sut) == "3BR"
                    }
                }
                context("attributes with bathrooms") {
                    beforeEach {
                        realEstateAttributes = RealEstateAttributes(propertyType: .other, offerType: .rent, bedrooms: nil, bathrooms: 3)
                        sut = realEstateAttributes.generatedTitle
                    }
                    it ("result should equal: OTHER For rent 3BA") {
                        expect(sut) == "OTHER For rent 3BA"
                    }
                }
            }
        }
    }
}
