//
//  CarSellerTypeSpec.swift
//  letgoTests
//
//  Created by Tomas Cobo on 19/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode


class CarSellerTypeSpec: QuickSpec {
    
    override func spec() {
        describe("CarSellerTypeSpec") {
            context("array of CarSellerType") {
                var sut : [CarSellerType]!
                var carSellerType: [CarSellerType] = []
                describe("both CarSellerType items") {
                    beforeEach {
                        sut = [CarSellerType.individual, CarSellerType.professional]
                    }
                    describe("Variant A - apply firstSection") {
                        beforeEach {
                            carSellerType = sut.carSectionsFrom(feature: .variantA, filter: FilterCarSection.firstSection)
                        }
                        it("it's not empty") {
                            expect(carSellerType).notTo(beEmpty())
                        }
                        it("contains individual") {
                            expect(carSellerType).toNot(contain(.individual))
                        }
                        it("not contains individual") {
                            expect(carSellerType).to(contain(.professional))
                        }
                    }
                    
                    describe("Variant C - apply firstSection") {
                        beforeEach {
                            carSellerType = sut.carSectionsFrom(feature: .variantC, filter: FilterCarSection.secondSection)
                        }
                        it("it's not empty") {
                            expect(carSellerType).notTo(beEmpty())
                        }
                        it("contains individual") {
                            expect(carSellerType).to(contain(.professional))
                        }
                        it("not contains individual") {
                            expect(carSellerType).toNot(contain(.individual))
                        }
                    }
                }
            }
        }
    }
}

