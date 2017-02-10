//
//  SignUpEmailStep1ViewModelSpec.swift
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

class SignUpEmailStep1ViewModelSpec: QuickSpec {
    var navigatorReceivedCancel: Bool = false
    var navigatorReceivedOpenHelp: Bool = false
    var navigatorReceivedOpenNextStep: Bool = false
    var navigatorReceivedOpenLogIn: Bool = false

    override func spec() {

        describe("SignUpEmailStep1ViewModel") {
            var keyValueStorage: MockKeyValueStorage!
            var email: String!
            var suggestedEmail: String!
            var nextStepEnabled: Bool!
            var tracker: MockTracker!
            var disposeBag: DisposeBag!
            var sut: SignUpEmailStep1ViewModel!

            beforeEach {
                self.navigatorReceivedCancel = false
                self.navigatorReceivedOpenHelp = false
                self.navigatorReceivedOpenNextStep = false
                self.navigatorReceivedOpenLogIn = false

                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                disposeBag = DisposeBag()
                sut = SignUpEmailStep1ViewModel(email: nil,
                                                isRememberedEmail: false,
                                                source: .sell,
                                                collapsedEmail: nil,
                                                keyValueStorage: keyValueStorage,
                                                tracker: tracker)
                sut.email.asObservable().subscribeNext { newEmail in
                    email = newEmail
                }.addDisposableTo(disposeBag)
                sut.suggestedEmail.subscribeNext { email in
                    suggestedEmail = email
                }.addDisposableTo(disposeBag)
                sut.nextStepEnabled.subscribeNext { enabled in
                    nextStepEnabled = enabled
                }.addDisposableTo(disposeBag)
                sut.navigator = self
            }

            describe("initialization") {
                context("did not log in previously") {
                    beforeEach {
                        sut = SignUpEmailStep1ViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has no email") {
                        expect(sut.email.value).to(beNil())
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        sut = SignUpEmailStep1ViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has an email") {
                        expect(sut.email.value) == "albert@letgo.com"
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }

                context("previously logged in by facebook") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "facebook"
                        keyValueStorage[.previousUserEmailOrName] = "Albert FB"

                        sut = SignUpEmailStep1ViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has no email") {
                        expect(sut.email.value).to(beNil())
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }

                context("previously logged in by google") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "google"
                        keyValueStorage[.previousUserEmailOrName] = "Albert Google"

                        sut = SignUpEmailStep1ViewModel(source: .sell, collapsedEmail: nil, keyValueStorage: keyValueStorage)
                    }

                    it("has no email") {
                        expect(sut.email.value).to(beNil())
                    }
                    it("has no password") {
                        expect(sut.password.value).to(beNil())
                    }
                    it("has next step disabled") {
                        expect(nextStepEnabled) == false
                    }
                }
            }

            describe("autosuggest email") {
                describe("empty") {
                    beforeEach {
                        sut.email.value = ""
                        sut.acceptSuggestedEmail()
                    }

                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == ""
                    }
                }

                describe("user letters") {
                    beforeEach {
                        sut.email.value = "albert"
                        sut.acceptSuggestedEmail()
                    }

                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert"
                    }
                }

                describe("user letters and @ sign") {
                    beforeEach {
                        sut.email.value = "albert@"
                        sut.acceptSuggestedEmail()
                    }

                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                        sut.acceptSuggestedEmail()
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert@"
                    }
                }

                describe("user letters, @ sign & first domain letters") {
                    beforeEach {
                        sut.email.value = "albert@g"
                        sut.acceptSuggestedEmail()
                    }

                    it("suggests first domain ocurrence") {
                        expect(suggestedEmail) == "albert@gmail.com"
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert@gmail.com"
                    }
                }
            }

            describe("open next step with email & password") {
                var errors: SignUpEmailStep1FormErrors!

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
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
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
                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
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
                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
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
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
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
                    sut.openHelp()
                }

                it("calls open help in navigator") {
                    expect(self.navigatorReceivedOpenHelp) == true
                }
            }

            describe("cancel") {
                beforeEach {
                    sut.cancel()
                }

                it("calls cancel in navigator") {
                    expect(self.navigatorReceivedCancel) == true
                }
            }
        }
    }
}

extension SignUpEmailStep1ViewModelSpec: SignUpEmailStep1Navigator {
    func cancelSignUpEmailStep1() {
        navigatorReceivedCancel = true
    }

    func openHelpFromSignUpEmailStep1() {
        navigatorReceivedOpenHelp = true
    }

    func openNextStepFromSignUpEmailStep1(email: String, password: String,
                                          isRememberedEmail: Bool, collapsedEmail: EventParameterCollapsedEmailField?) {
        navigatorReceivedOpenNextStep = true
    }

    func openLogInFromSignUpEmailStep1(email: String?,
                                       isRememberedEmail: Bool, collapsedEmail: EventParameterCollapsedEmailField?) {
        navigatorReceivedOpenLogIn = true
    }
}
