//
//  PostingDetailsStepSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 25/10/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble


class PostingDetailStepSpec: BaseViewModelSpec {

    
    override func spec() {
        describe("PostListingStateSpec") {
            var sut: PostingDetailStep!
            context("current step: property type") {
                beforeEach {
                    sut = PostingDetailStep.propertyType
                }
                describe("next step") {
                    it("next step is offerType") {
                        expect(sut.nextStep(postingFlowType: .standard)) == PostingDetailStep.offerType
                    }
                }
            }
            context("current step: offerType") {
                beforeEach {
                    sut = PostingDetailStep.offerType
                }
                describe("next step") {
                    context("posting flow type is standard") {
                        it("next step is bedrooms") {
                            expect(sut.nextStep(postingFlowType: .standard)) == PostingDetailStep.bedrooms
                        }
                    }
                    context("posting flow type is turkish") {
                        it("next step is rooms") {
                            expect(sut.nextStep(postingFlowType: .turkish)) == PostingDetailStep.rooms
                        }
                    }
                }
            }
            context("current step: bedrooms") {
                beforeEach {
                    sut = PostingDetailStep.bedrooms
                }
                describe("next step") {
                    it("next step is bathrooms") {
                        expect(sut.nextStep(postingFlowType: .standard)) == PostingDetailStep.bathrooms
                    }
                }
            }
            context("current step: rooms") {
                beforeEach {
                    sut = PostingDetailStep.rooms
                }
                describe("next step") {
                    it("next step is size Square meters") {
                        expect(sut.nextStep(postingFlowType: .turkish)) == PostingDetailStep.sizeSquareMeters
                    }
                }
            }
            context("current step: size Square meters") {
                beforeEach {
                    sut = PostingDetailStep.sizeSquareMeters
                }
                describe("next step") {
                    it("next step is summay") {
                        expect(sut.nextStep(postingFlowType: .turkish)) == PostingDetailStep.summary
                    }
                }
            }
            context("current step: bathrooms") {
                beforeEach {
                    sut = PostingDetailStep.bathrooms
                }
                describe("next step") {
                    it("next step is summary") {
                        expect(sut.nextStep(postingFlowType: .standard)) == PostingDetailStep.summary
                    }
                }
            }
            context("current step: summary") {
                beforeEach {
                    sut = PostingDetailStep.summary
                }
                describe("next step") {
                    it("next step is nil") {
                        expect(sut.nextStep(postingFlowType: .standard)).to(beNil())
                    }
                }
            }
        }
    }
}
