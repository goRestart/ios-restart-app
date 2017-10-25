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
                        expect(sut.nextStep) == PostingDetailStep.offerType
                    }
                }
            }
            context("current step: offerType") {
                beforeEach {
                    sut = PostingDetailStep.offerType
                }
                describe("next step") {
                    it("next step is bedrooms") {
                        expect(sut.nextStep) == PostingDetailStep.bedrooms
                    }
                }
            }
            context("current step: bedrooms") {
                beforeEach {
                    sut = PostingDetailStep.bedrooms
                }
                describe("next step") {
                    it("next step is bathrooms") {
                        expect(sut.nextStep) == PostingDetailStep.bathrooms
                    }
                }
            }
            context("current step: bathrooms") {
                beforeEach {
                    sut = PostingDetailStep.bathrooms
                }
                describe("next step") {
                    it("next step is summary") {
                        expect(sut.nextStep) == PostingDetailStep.summary
                    }
                }
            }
            context("current step: summary") {
                beforeEach {
                    sut = PostingDetailStep.summary
                }
                describe("next step") {
                    it("next step is nil") {
                        expect(sut.nextStep).to(beNil())
                    }
                }
            }
        }
    }
}
