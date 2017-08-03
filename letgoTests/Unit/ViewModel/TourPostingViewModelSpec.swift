//
//  TourPostingViewModelSpec.swift
//  LetGo
//
//  Created by Juan Iglesias on 02/08/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result


class TourPostingViewModelSpec: BaseViewModelSpec {
    
    override func spec() {
        describe("TourPostingViewModelSpec") {
            var sut: TourPostingViewModel!
            let featureFlags = MockFeatureFlags()
            fdescribe("texts on screen") {
                context("feature flags copiesImprovementOnboarding = B") {
                    beforeEach {
                        featureFlags.copiesImprovementOnboarding = .b
                        sut = TourPostingViewModel(featureFlags: featureFlags)
                    }
                    it ("title is option 'Selling is easy...'") {
                        expect(sut.titleText) == LGLocalizedString.onboardingPostingImprovementBTitle
                    }
                    it("subtitle is empty") {
                        expect(sut.subtitleText) == ""
                    }
                    it("button text is 'Start'") {
                        expect(sut.okButtonText) == LGLocalizedString.onboardingPostingButtonB
                    }
                }
                context("feature flags copiesImprovementOnboarding = C") {
                    beforeEach {
                        featureFlags.copiesImprovementOnboarding = .c
                        sut = TourPostingViewModel(featureFlags: featureFlags)
                    }
                    it ("title is option 'Selling is easy...'") {
                        expect(sut.titleText) == LGLocalizedString.onboardingPostingImprovementCTitle
                    }
                    it("subtitle is empty") {
                        expect(sut.subtitleText) == ""
                    }
                    it("button text is 'Try it out'") {
                        expect(sut.okButtonText) == LGLocalizedString.onboardingPostingImprovementCButton
                    }
                }
                context("feature flags copiesImprovementOnboarding = D") {
                    beforeEach {
                        featureFlags.copiesImprovementOnboarding = .d
                        sut = TourPostingViewModel(featureFlags: featureFlags)
                    }
                    it ("title is option 'Post in one step...'") {
                        expect(sut.titleText) == LGLocalizedString.onboardingPostingImprovementDTitle
                    }
                    it("subtitle is empty") {
                        expect(sut.subtitleText) == ""
                    }
                    it("button text is 'Start'") {
                        expect(sut.okButtonText) == LGLocalizedString.onboardingPostingButtonB
                    }
                }
                context("feature flags copiesImprovementOnboarding = E") {
                    beforeEach {
                        featureFlags.copiesImprovementOnboarding = .e
                        sut = TourPostingViewModel(featureFlags: featureFlags)
                    }
                    it ("title is option 'Selling is easy: just take a picture...'") {
                        expect(sut.titleText) == LGLocalizedString.onboardingPostingImprovementETitle
                    }
                    it("subtitle is empty") {
                        expect(sut.subtitleText) == ""
                    }
                    it("button text is 'Start'") {
                        expect(sut.okButtonText) == LGLocalizedString.onboardingPostingButtonB
                    }
                }
                context("feature flags copiesImprovementOnboarding = F") {
                    beforeEach {
                        featureFlags.copiesImprovementOnboarding = .f
                        sut = TourPostingViewModel(featureFlags: featureFlags)
                    }
                    it ("title is option 'Post an item in just a seconds...'") {
                        expect(sut.titleText) == LGLocalizedString.onboardingPostingImprovementFTitle
                    }
                    it("subtitle is empty") {
                        expect(sut.subtitleText) == ""
                    }
                    it("button text is 'Start'") {
                        expect(sut.okButtonText) == LGLocalizedString.onboardingPostingButtonB
                    }
                }
            }
        }
    }
}

extension TourPostingViewModelSpec: TourPostingNavigator {
    func tourPostingClose() {}
    func tourPostingPost(fromCamera: Bool) {}
}
