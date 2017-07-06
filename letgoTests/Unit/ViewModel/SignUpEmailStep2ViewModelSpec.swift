//
//  SignUpEmailStep2ViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 11/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift

class SignUpEmailStep2ViewModelSpec: BaseViewModelSpec {
    var navigatorReceivedOpenHelp: Bool = false
    var navigatorReceivedOpenRecaptcha: Bool = false
    var navigatorReceivedOpenScammerAlert: Bool = false
    var navigatorReceivedCloseAfterSignUp: Bool = false

    override func spec() {

        describe("SignUpEmailStep2ViewModel") {
            var signUpEnabled: Bool!
            var disposeBag: DisposeBag!
            var featureFlags: MockFeatureFlags!
            var sessionManager: MockSessionManager!
            var installationRepository: MockInstallationRepository!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!
            var sut: SignUpEmailStep2ViewModel!

            beforeEach {
                self.resetViewModelSpec()
                self.navigatorReceivedOpenRecaptcha = false
                self.navigatorReceivedOpenScammerAlert = false
                self.navigatorReceivedOpenHelp = false
                self.navigatorReceivedCloseAfterSignUp = false

                disposeBag = DisposeBag()
                featureFlags = MockFeatureFlags()
                sessionManager = MockSessionManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()

                let email = "albert.hernandez@gmail.com"
                var myUser = MockMyUser.makeMock()
                myUser.email = email
                sessionManager.signUpResult = SignupResult(value: myUser)
                sessionManager.logInResult = LoginResult(value: myUser)
                installationRepository = MockInstallationRepository()
                installationRepository.installationVar.value = MockInstallation.makeMock()
                sut = SignUpEmailStep2ViewModel(email: email, isRememberedEmail: false, password: "654321",
                                                source: .sell,
                                                sessionManager: sessionManager,
                                                installationRepository: installationRepository,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: featureFlags,
                                                tracker: tracker)
                sut.signUpEnabled.subscribeNext { enabled in
                    signUpEnabled = enabled
                }.addDisposableTo(disposeBag)
                sut.delegate = self
                sut.navigator = self
            }

            describe("initialization") {
                context("common") {
                    it("has the email passed by in the init") {
                        expect(sut.email) == "albert.hernandez@gmail.com"
                    }
                    it("has a suggested username") {
                        expect(sut.username.value) == "Albert Hernandez"
                    }
                    it("does not have terms and conditions accept required") {
                        expect(sut.termsAndConditionsAcceptRequired) == false
                    }
                    it("does not have newsletter accept required") {
                        expect(sut.newsLetterAcceptRequired) == false
                    }
                    it("has sign up enabled") {
                        expect(signUpEnabled) == true
                    }
                    it("has terms and conditions URL") {
                        expect(sut.termsAndConditionsURL).notTo(beNil())
                    }
                    it("has privacy policy URL") {
                        expect(sut.privacyURL).notTo(beNil())
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

            describe("sign up button press with invalid form") {
                var errors: SignUpEmailStep2FormErrors!

                context("username empty") {
                    beforeEach {
                        sut.username.value = ""
                        errors = sut.signUpButtonPressed()
                    }

                    it("has the sign up disabled") {
                        expect(signUpEnabled) == false
                    }
                    it("does not return any error") {
                        expect(errors) == []
                    }
                    it("does not track a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                }

                context("username containing letgo keyword") {
                    beforeEach {
                        sut.username.value = "albert letgo"
                        errors = sut.signUpButtonPressed()
                    }

                    it("has the sign up enabled") {
                        expect(signUpEnabled) == true
                    }
                    it("returns username contains letgo error") {
                        expect(errors) == [.usernameContainsLetgo]
                    }
                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                }

                context("short username") {
                    beforeEach {
                        sut.username.value = "a"
                        errors = sut.signUpButtonPressed()
                    }

                    it("has the sign up enabled") {
                        expect(signUpEnabled) == true
                    }
                    it("returns a short username error") {
                        expect(errors) == [.shortUsername]
                    }
                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                }

                context("valid username but terms and conditions & newsletter required and not accepted") {
                    beforeEach {
                        featureFlags.signUpEmailNewsletterAcceptRequired = true
                        featureFlags.signUpEmailTermsAndConditionsAcceptRequired = true

                        sut.username.value = "Albert"
                        errors = sut.signUpButtonPressed()
                    }

                    it("has the sign up enabled") {
                        expect(signUpEnabled) == true
                    }
                    it("returns terms and conditions not accepted error") {
                        expect(errors) == [.termsAndConditionsNotAccepted]
                    }
                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                }
            }

            describe("sign up with valid form") {
                var errors: SignUpEmailStep2FormErrors!

                beforeEach {
                    sut.username.value = "Albert"
                    errors = sut.signUpButtonPressed()
                }

                it("has the sign up enabled") {
                    expect(signUpEnabled) == true
                }
                it("does not return any error") {
                    expect(errors) == []
                }
                it("calls show and hide loading in delegate") {
                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                }
            }

            context("valid form") {
                beforeEach {
                    sut.username.value = "Albert"
                }

                describe("sign up fails with scammer error") {
                    beforeEach {
                        sessionManager.signUpResult = SignupResult(error: .scammer)
                        _ = sut.signUpButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                    it("calls open scammer alert in navigator") {
                        expect(self.navigatorReceivedOpenScammerAlert).toEventually(beTrue())
                    }
                }

                describe("sign up fails with user not verified error") {
                    beforeEach {
                        sessionManager.signUpResult = SignupResult(error: .userNotVerified)
                        _ = sut.signUpButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                    it("calls open recaptcha in navigator") {
                        expect(self.navigatorReceivedOpenRecaptcha).toEventually(beTrue())
                    }
                }

                describe("sign up fails with conflict user exists error") {
                    beforeEach {
                        sessionManager.signUpResult = SignupResult(error: .conflict(cause: .userExists))
                    }

                    describe("auto log in fails") {
                        beforeEach {
                            sessionManager.logInResult = LoginResult(error: .network)
                            _ = sut.signUpButtonPressed()

                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }

                        it("tracks a signupError event") {
                            let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError]
                        }
                        it("does not call close after signup in navigator") {
                            expect(self.navigatorReceivedCloseAfterSignUp) == false
                        }
                    }

                    describe("auto log in succeeds") {
                        let email = "albert.hernandez@gmail.com"

                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.email = email
                            sessionManager.logInResult = LoginResult(value: myUser)
                            _ = sut.signUpButtonPressed()

                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }

                        it("tracks a loginEmail event") {
                            let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmail]
                        }
                        it("calls close after signup in navigator when signup succeeds") {
                            expect(self.navigatorReceivedCloseAfterSignUp).toEventually(beTrue())
                        }
                        it("saves letgo as previous user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider) == "letgo"
                        }
                        it("saves the user email as previous email") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username) == email
                        }
                    }
                }

                describe("sign up fails with other reason") {
                    beforeEach {
                        sessionManager.signUpResult = SignupResult(error: .network)
                        _ = sut.signUpButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                    it("does not call close after signup in navigator") {
                        expect(self.navigatorReceivedCloseAfterSignUp) == false
                    }
                }

                describe("sign up succeeds") {
                    let email = "albert.hernandez@gmail.com"

                    beforeEach {
                        var myUser = MockMyUser.makeMock()
                        myUser.email = email
                        sessionManager.signUpResult = SignupResult(value: myUser)
                        _ = sut.signUpButtonPressed()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a signupEmail event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupEmail]
                    }
                    it("calls close after signup in navigator when signup succeeds") {
                        expect(self.navigatorReceivedCloseAfterSignUp).toEventually(beTrue())
                    }
                    it("saves letgo as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "letgo"
                    }
                    it("saves the user email as previous email") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == email
                    }
                }
            }

            describe("help button press") {
                beforeEach {
                    sut.helpButtonPressed()
                }

                it("calls open help in navigator") {
                    expect(self.navigatorReceivedOpenHelp) == true
                }
            }
        }
    }
}

extension SignUpEmailStep2ViewModelSpec: SignUpEmailStep2ViewModelDelegate {}

extension SignUpEmailStep2ViewModelSpec: SignUpEmailStep2Navigator {
    func openHelpFromSignUpEmailStep2() {
        navigatorReceivedOpenHelp = true
    }

    func openRecaptchaFromSignUpEmailStep2(transparentMode: Bool) {
        navigatorReceivedOpenRecaptcha = true
    }

    func openScammerAlertFromSignUpEmailStep2(contactURL: URL) {
        navigatorReceivedOpenScammerAlert = true
    }

    func closeAfterSignUpSuccessful() {
        navigatorReceivedCloseAfterSignUp = true
    }
}
