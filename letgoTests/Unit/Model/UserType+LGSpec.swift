//
//  UserType+LGSpec.swift
//  letgoTests
//
//  Created by Tomas Cobo on 19/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Quick
import Nimble
import LGCoreKit
@testable import LetGoGodMode


final class UserTypeTypeSpec: QuickSpec {
    
    override func spec() {
        describe("UserTypeTypeSpec") {
            context("array of UserType") {
                var sut : [UserType]!
                var carSellerType: [UserType] = []
                describe("both UserType items") {
                    beforeEach {
                        sut = [.user, .pro]
                    }
                    describe("Variant A - apply firstSection") {
                        beforeEach {
                            carSellerType = sut.carSectionsFrom(feature: .variantA, filter: FilterCarSection.firstSection)
                        }
                        it("it's not empty") {
                            expect(carSellerType).notTo(beEmpty())
                        }
                        it("NOT contains user") {
                            expect(carSellerType).toNot(contain(.user))
                        }
                        it("contains pro") {
                            expect(carSellerType).to(contain(.pro))
                        }
                    }
                    
                    describe("Variant C - apply secondSection") {
                        beforeEach {
                            carSellerType = sut.carSectionsFrom(feature: .variantC, filter: FilterCarSection.secondSection)
                        }
                        it("it's not empty") {
                            expect(carSellerType).notTo(beEmpty())
                        }
                        it("contains pro") {
                            expect(carSellerType).to(contain(.pro))
                        }
                        it("NOT contains user") { 
                            expect(carSellerType).toNot(contain(.user))
                        }
                    }
                }
            }
        }
    }
}

