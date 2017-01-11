//
//  SignUpStep1ViewModelSpec.swift
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

class SignUpStep1ViewModelSpec: QuickSpec {
    var navigatorReceivedOpenHelp: Bool = false
    var navigatorReceivedOpenNextStep: Bool = false
    var navigatorReceivedOpenLogIn: Bool = false

    override func spec() {

        describe("SignUpStep1ViewModel") {
            var keyValueStorage: MockKeyValueStorage!
            var nextStepEnabled: Bool!
            var disposeBag: DisposeBag!
            var sut: SignUpStep1ViewModel!

            beforeEach {
                self.navigatorReceivedOpenHelp = false
                self.navigatorReceivedOpenNextStep = false
                self.navigatorReceivedOpenLogIn = false

                keyValueStorage = MockKeyValueStorage()
                disposeBag = DisposeBag()
                sut = SignUpStep1ViewModel(keyValueStorage: keyValueStorage)
                sut.nextStepEnabled.subscribeNext { enabled in
                    nextStepEnabled = enabled
                }.addDisposableTo(disposeBag)
                sut.navigator = self
            }

            describe("initialization") {
                context("did not log in previously") {
                    beforeEach {
                        sut = SignUpStep1ViewModel(keyValueStorage: keyValueStorage)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        sut = SignUpStep1ViewModel(keyValueStorage: keyValueStorage)
                    }

                    it("has an email") {
                        expect(sut.email.value) == "albert@letgo.com"
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }

                context("previously logged in by facebook") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "facebook"
                        keyValueStorage[.previousUserEmailOrName] = "Albert FB"

                        sut = SignUpStep1ViewModel(keyValueStorage: keyValueStorage)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }

                context("previously logged in by google") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "google"
                        keyValueStorage[.previousUserEmailOrName] = "Albert Google"

                        sut = SignUpStep1ViewModel(keyValueStorage: keyValueStorage)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }
            }

            context("open next step with email & password") {
                var errors: [SignUpStep1FormError]!

                describe("empty") {
                    beforeEach {
                        sut.email.value = ""
                        sut.password.value = ""
                        errors = sut.openNextStep()
                    }

                    it("has the next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                    it("does not return any error") {
                        expect(errors) == []
                    }
                    it("does not call open next step in navigator") {
                        expect(self.navigatorReceivedOpenNextStep) == false
                    }
                }

                describe("with email non-valid & short password") {
                    beforeEach {
                        sut.email.value = "a"
                        sut.password.value = "a"
                        errors = sut.openNextStep()
                    }

                    it("has the next step enabled") {
                        expect(nextStepEnabled) == true
                    }
                    it("returns that the email is invalid and the password is short") {
                        expect(errors) == [.invalidEmail, .shortPassword]
                    }
                    it("does not call open next step in navigator") {
                        expect(self.navigatorReceivedOpenNextStep) == false
                    }
                }

                describe("with valid email & long password") {
                    beforeEach {
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "abcdefghijklmnopqrstuvwxyz"
                        errors = sut.openNextStep()
                    }

                    it("has the next step enabled") {
                        expect(nextStepEnabled) == true
                    }
                    it("returns that the password is long") {
                        expect(errors) == [.longPassword]
                    }
                    it("does not call open next step in navigator") {
                        expect(self.navigatorReceivedOpenNextStep) == false
                    }
                }

                describe("with valid email & password") {
                    beforeEach {
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "letitgo"
                        errors = sut.openNextStep()
                    }

                    it("has the next step enabled") {
                        expect(nextStepEnabled) == true
                    }
                    it("returns no errors") {
                        expect(errors) == []
                    }
                    it("calls open next step in navigator") {
                        expect(self.navigatorReceivedOpenNextStep) == true
                    }
                }
            }

            describe("open login") {
                beforeEach {
                    sut.openLogIn()
                }

                it("calls open login in navigator") {
                    expect(self.navigatorReceivedOpenLogIn) == true
                }
            }

            describe("open help") {
                beforeEach {
                    sut.helpAction.action()
                }

                it("calls open help in navigator") {
                    expect(self.navigatorReceivedOpenHelp) == true
                }
            }
        }
    }
}

extension SignUpStep1ViewModelSpec: SignUpStep1Navigator {
    func openHelpFromSignUpStep1() {
        navigatorReceivedOpenHelp = true
    }

    func openNextStepFromSignUpStep1(email email: String, password: String) {
        navigatorReceivedOpenNextStep = true
    }

    func openLogInFromSignUpStep1(email email: String, password: String) {
        navigatorReceivedOpenLogIn = true
    }
}
