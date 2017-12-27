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
        var sut: RealEstateAttributes!
        
        describe("Generate real estate posting") {
            context("with no data on attributes") {
                beforeEach {
                    sut = RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: nil, bathrooms: nil)
                }
                it ("returns empty title") {
                    expect(sut.generateTitle()) == ""
                }
                context("attributes with property and offertype") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .other, offerType: .rent, bedrooms: nil, bathrooms: nil)
                    }
                    it ("result should equal: OTHER For rent") {
                        expect(sut.generateTitle()) == "OTHER For rent"
                    }
                }
                context("attributes with bedrooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: 3, bathrooms: nil)
                    }
                    it ("result should equal: 3BR") {
                        expect(sut.generateTitle()) == "3BR"
                    }
                }
                context("attributes with bathrooms") {
                    beforeEach {
                        sut = RealEstateAttributes(propertyType: .other, offerType: .rent, bedrooms: nil, bathrooms: 3)
                    }
                    it ("result should equal: OTHER For rent 3BA") {
                        expect(sut.generateTitle()) == "OTHER For rent 3BA"
                    }
                }
            }
        }
        
        describe("Generate real estate attribute tags") {
            context("with attributes") {
                beforeEach {
                    sut = RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: nil, bathrooms: nil)
                }
                it ("returns empty array") {
                    expect(sut.generateTags().count).to(equal(0))
                }
            }
            context("with 0 bathrooms") {
                beforeEach {
                    sut = RealEstateAttributes(propertyType: nil, offerType: nil, bedrooms: nil, bathrooms: 0)
                }
                it ("returns 1 tag") {
                    let tags = sut.generateTags()
                    expect(tags.count).to(equal(1))
                    expect(tags[0]).to(equal("0BA"))
                }
            }
            context("with all attributes") {
                beforeEach {
                    sut = RealEstateAttributes(propertyType: .house, offerType: .rent, bedrooms: 2, bathrooms: 1)
                }
                it ("returns 4 tags") {
                    let tags = sut.generateTags()
                    expect(tags.count).to(equal(4))
                    expect(tags[0]).to(equal("HOUSE"))
                    expect(tags[1]).to(equal("For Rent"))
                    expect(tags[2]).to(equal("2BR"))
                    expect(tags[3]).to(equal("1BA"))
                }
            }
            
        }
    }
}
