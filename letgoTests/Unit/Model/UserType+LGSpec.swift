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
                    describe("deselect individual") {
                        beforeEach {
                            carSellerType = sut.toogleFilterCarSection(filter: .individual)
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
                }
            }
        }
    }
}

