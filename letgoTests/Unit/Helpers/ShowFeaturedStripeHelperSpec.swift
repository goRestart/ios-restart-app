//
//  ShowFeaturedStripeHelperSpec.swift
//  LetGo
//
//  Created by Dídac on 09/02/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class ShowFeaturedStripeHelperSpec: QuickSpec {
    override func spec() {
        var sut: ShowFeaturedStripeHelper!

        var myUserRepository: MockMyUserRepository!
        var featureFlags: MockFeatureFlags!
        var product: MockProduct!

        describe("ShowFeaturedStripeHelperSpec") {
            beforeEach {
                myUserRepository = MockMyUserRepository()
                featureFlags = MockFeatureFlags()
                product = MockProduct.makeMock()
                sut = ShowFeaturedStripeHelper(featureFlags: featureFlags, myUserRepository: myUserRepository)
            }
            describe("Product is not featured") {
                beforeEach {
                    product.featured = false
                }
                context("feature flag is not active") {
                    beforeEach {
                        featureFlags.pricedBumpUpEnabled = false
                    }
                    context("product is mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Mario"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("Doesn't show featured stripe") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == false
                        }
                    }
                    context("product is NOT mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Luigi"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("Doesn't show featured stripe") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == false
                        }
                    }
                }
                context("feature flag is active") {
                    beforeEach {
                        featureFlags.pricedBumpUpEnabled = true
                    }
                    context("product is mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Mario"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("Doesn't show featured stripe") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == false
                        }
                    }
                    context("product is NOT mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Luigi"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("Doesn't show featured stripe") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == false
                        }
                    }
                }
            }
            describe("Product is featured") {
                beforeEach {
                    product.featured = true
                }
                context("feature flag is not active") {
                    beforeEach {
                        featureFlags.pricedBumpUpEnabled = false
                    }
                    context("product is mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Mario"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("featured stripe should be shown") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == true
                        }
                    }
                    context("product is NOT mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Luigi"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("Doesn't show featured stripe") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == false
                        }
                    }
                }
                context("feature flag is active") {
                    beforeEach {
                        featureFlags.pricedBumpUpEnabled = true
                    }
                    context("product is mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Mario"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("featured stripe should be shown") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == true
                        }
                    }
                    context("product is NOT mine") {
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.objectId = "Mario"
                            var user = MockUserProduct.makeMock()
                            user.objectId = "Luigi"
                            product.user = user
                            myUserRepository.myUserVar.value = myUser
                        }
                        it("featured stripe should be shown") {
                            expect(sut.shouldShowFeaturedStripeFor(product)) == true
                        }
                    }
                }
            }
        }
    }
}
