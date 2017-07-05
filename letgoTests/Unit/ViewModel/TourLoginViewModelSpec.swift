//
//  TourLoginViewModelSpec.swift
//  LetGo
//
//  Created by Eli Kohen on 20/01/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift
import RxTest


class TourLoginViewModelSpec: QuickSpec {

    override func spec() {

        var sut: TourLoginViewModel!
        var featureFlags: MockFeatureFlags!
        var signupViewModel: SignUpViewModel!

        var disposeBag: DisposeBag!
        var stateObserver: TestableObserver<TourLoginState>!

        describe("TourLoginViewModelSpec") {

            func createTourLoginViewModel() {
                sut = TourLoginViewModel(signUpViewModel: signupViewModel, featureFlags: featureFlags, syncTimeout: 0.2)

                disposeBag = nil
                disposeBag = DisposeBag()
                sut.state.asObservable().bindTo(stateObserver).addDisposableTo(disposeBag)
            }

            describe("style initialisation") {
                beforeEach {
                    featureFlags = MockFeatureFlags()
                    featureFlags.trackingDataVar.value = nil

                    let sessionManager = MockSessionManager()
                    let installationRepository = MockInstallationRepository()
                    let keyValueStorage = MockKeyValueStorage()
                    let tracker = MockTracker()
                    let myUser = MockMyUser.makeMock()
                    let googleLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                    let fbLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                    signupViewModel = SignUpViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                                          keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .dark,
                                          source: .install, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)

                    let scheduler = TestScheduler(initialClock: 0)
                    scheduler.start()
                    stateObserver = scheduler.createObserver(TourLoginState.self)
                }
                context("flags doesn't synchronize") {
                    beforeEach {
                        createTourLoginViewModel()
                    }
                    it("sets default status .active(closeEnabled: true, emailAsField: true)") {
                        expect(stateObserver.eventValues).toEventually(equal([.loading, .active(closeEnabled: true, emailAsField: true)]))
                    }
                    it("sets collapsedEmailTrackingParam as unset in signupViewModel") {
                        expect(signupViewModel.collapsedEmailTrackingParam).toEventually(equal(EventParameterBoolean.notAvailable))
                    }
                }
                context("flags syncrhonize") {
                    context("testA") {
                        beforeEach {
                            createTourLoginViewModel()
                            featureFlags.onboardingReview = .testA
                            featureFlags.trackingDataVar.value = ["testA-true"]
                        }
                        it("sets status .active(closeEnabled: true, emailAsField: true)") {
                            XCTAssertEqual(stateObserver.events, [next(0, .loading), next(0, .active(closeEnabled: true, emailAsField: true))])
                        }
                        it("sets collapsedEmailTrackingParam as false in signupViewModel") {
                            expect(signupViewModel.collapsedEmailTrackingParam) == .falseParameter
                        }
                    }
                    context("testB") {
                        beforeEach {
                            createTourLoginViewModel()
                            featureFlags.onboardingReview = .testB
                            featureFlags.trackingDataVar.value = ["testB-true"]
                        }
                        it("sets status .active(closeEnabled: false, emailAsField: true)") {
                            XCTAssertEqual(stateObserver.events, [next(0, .loading), next(0, .active(closeEnabled: false, emailAsField: true))])
                        }
                        it("sets collapsedEmailTrackingParam as false in signupViewModel") {
                            expect(signupViewModel.collapsedEmailTrackingParam) == .falseParameter
                        }
                    }
                    context("testC") {
                        beforeEach {
                            createTourLoginViewModel()
                            featureFlags.onboardingReview = .testC
                            featureFlags.trackingDataVar.value = ["testC-true"]
                        }
                        it("sets status .active(closeEnabled: true, emailAsField: false)") {
                            XCTAssertEqual(stateObserver.events, [next(0, .loading), next(0, .active(closeEnabled: true, emailAsField: false))])
                        }
                        it("sets collapsedEmailTrackingParam as true in signupViewModel") {
                            expect(signupViewModel.collapsedEmailTrackingParam) == .trueParameter
                        }
                    }
                    context("testD") {
                        beforeEach {
                            createTourLoginViewModel()
                            featureFlags.onboardingReview = .testD
                            featureFlags.trackingDataVar.value = ["testD-true"]
                        }
                        it("sets status .active(closeEnabled: false, emailAsField: false)") {
                            XCTAssertEqual(stateObserver.events, [next(0, .loading), next(0, .active(closeEnabled: false, emailAsField: false))])
                        }
                        it("sets collapsedEmailTrackingParam as true in signupViewModel") {
                            expect(signupViewModel.collapsedEmailTrackingParam) == .trueParameter
                        }
                    }
                }
            }
        }
    }
}
