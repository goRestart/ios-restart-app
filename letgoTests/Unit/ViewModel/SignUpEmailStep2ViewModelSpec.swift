//
//  SignUpEmailStep2ViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift

class SignUpEmailStep2ViewModelSpec: QuickSpec {
//    var navigatorReceivedOpenHelp: Bool = false
//    var navigatorReceivedOpenNextStep: Bool = false
//    var navigatorReceivedOpenLogIn: Bool = false

    override func spec() {

        fdescribe("SignUpEmailStep2ViewModel") {
//            var keyValueStorage: MockKeyValueStorage!
            var signUpEnabled: Bool!
            var disposeBag: DisposeBag!
            var featureFlags: MockFeatureFlags!
            var sut: SignUpEmailStep2ViewModel!

            beforeEach {
//                self.navigatorReceivedOpenHelp = false
//                self.navigatorReceivedOpenNextStep = false
//                self.navigatorReceivedOpenLogIn = false

//                keyValueStorage = MockKeyValueStorage()
                disposeBag = DisposeBag()
                featureFlags = MockFeatureFlags()
//                sut = SignUpEmailStep1ViewModel(keyValueStorage: keyValueStorage)
                sut = SignUpEmailStep2ViewModel(email: "albert@letgo.com", password: "654321",
                                                featureFlags: featureFlags)
                sut.signUpEnabled.subscribeNext { enabled in
                    signUpEnabled = enabled
                }.addDisposableTo(disposeBag)
//                sut.navigator = self
            }

            describe("initialization") {
                context("common") {
                    it("has the email passed by in the init") {
                        expect(sut.email) == "albert@letgo.com"
                    }
                    it("has an empty username") {
                        expect(sut.username.value) == ""
                    }
                    it("does not have terms and conditions accept required") {
                        expect(sut.termsAndConditionsAcceptRequired) == false
                    }
                    it("does not have newsletter accept required") {
                        expect(sut.newsLetterAcceptRequired) == false
                    }
                    it("does not have sign up enabled") {
                        expect(signUpEnabled) == false
                    }
                }
            }

            describe("feature flags") {
                context("newsletter accept enabled") {
                    beforeEach {
                        featureFlags.signUpEmailNewsletterAcceptRequired = true
                    }

                    it("does not have newsletter accept required") {
                        expect(sut.newsLetterAcceptRequired) == true
                    }
                }

                context("terms and conditions accept enabled") {
                    beforeEach {
                        featureFlags.signUpEmailTermsAndConditionsAcceptRequired = true
                    }

                    it("does not have newsletter accept required") {
                        expect(sut.termsAndConditionsAcceptRequired) == true
                    }
                }
            }

//            context("open next step with email & password") {
//                var errors: [SignUpEmailStep1FormError]!
//
//                describe("empty") {
//                    beforeEach {
//                        sut.email.value = ""
//                        sut.password.value = ""
//                        errors = sut.openNextStep()
//                    }
//
//                    it("has the next step disabled") {
//                        expect(nextStepEnabled) == false
//                    }
//                    it("does not return any error") {
//                        expect(errors) == []
//                    }
//                    it("does not call open next step in navigator") {
//                        expect(self.navigatorReceivedOpenNextStep) == false
//                    }
//                }
//
//                describe("with email non-valid & short password") {
//                    beforeEach {
//                        sut.email.value = "a"
//                        sut.password.value = "a"
//                        errors = sut.openNextStep()
//                    }
//
//                    it("has the next step enabled") {
//                        expect(nextStepEnabled) == true
//                    }
//                    it("returns that the email is invalid and the password is short") {
//                        expect(errors) == [.invalidEmail, .shortPassword]
//                    }
//                    it("does not call open next step in navigator") {
//                        expect(self.navigatorReceivedOpenNextStep) == false
//                    }
//                }
//
//                describe("with valid email & long password") {
//                    beforeEach {
//                        sut.email.value = "albert@letgo.com"
//                        sut.password.value = "abcdefghijklmnopqrstuvwxyz"
//                        errors = sut.openNextStep()
//                    }
//
//                    it("has the next step enabled") {
//                        expect(nextStepEnabled) == true
//                    }
//                    it("returns that the password is long") {
//                        expect(errors) == [.longPassword]
//                    }
//                    it("does not call open next step in navigator") {
//                        expect(self.navigatorReceivedOpenNextStep) == false
//                    }
//                }
//
//                describe("with valid email & password") {
//                    beforeEach {
//                        sut.email.value = "albert@letgo.com"
//                        sut.password.value = "letitgo"
//                        errors = sut.openNextStep()
//                    }
//
//                    it("has the next step enabled") {
//                        expect(nextStepEnabled) == true
//                    }
//                    it("returns no errors") {
//                        expect(errors) == []
//                    }
//                    it("calls open next step in navigator") {
//                        expect(self.navigatorReceivedOpenNextStep) == true
//                    }
//                }
//            }

//            describe("open login") {
//                beforeEach {
//                    sut.openLogIn()
//                }
//
//                it("calls open login in navigator") {
//                    expect(self.navigatorReceivedOpenLogIn) == true
//                }
//            }
//
//            describe("open help") {
//                beforeEach {
//                    sut.helpAction.action()
//                }
//
//                it("calls open help in navigator") {
//                    expect(self.navigatorReceivedOpenHelp) == true
//                }
//            }
        }
    }
}

//extension SignUpEmailStep2ViewModelSpec: SignUpEmailStep2Navigator {
//    func openHelpFromSignUpEmailStep1() {
//        navigatorReceivedOpenHelp = true
//    }
//
//    func openNextStepFromSignUpEmailStep1(email email: String, password: String) {
//        navigatorReceivedOpenNextStep = true
//    }
//
//    func openLogInFromSignUpEmailStep1(email email: String, password: String) {
//        navigatorReceivedOpenLogIn = true
//    }
//}
