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
    var delegateReceivedShowLoading: Bool = false
    var delegateReceivedHideLoading: Bool = false

    var navigatorReceivedOpenHelp: Bool = false
    var navigatorReceivedOpenRecaptcha: Bool = false
    var navigatorReceivedOpenScammerAlert: Bool = false
    var navigatorReceivedCloseAfterSignUp: Bool = false

    override func spec() {

        fdescribe("SignUpEmailStep2ViewModel") {
            var signUpEnabled: Bool!
            var disposeBag: DisposeBag!
            var featureFlags: MockFeatureFlags!
            var sessionManager: MockSessionManager!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!
            var sut: SignUpEmailStep2ViewModel!

            beforeEach {
                self.delegateReceivedShowLoading = false
                self.delegateReceivedHideLoading = false
                self.navigatorReceivedOpenRecaptcha = false
                self.navigatorReceivedOpenScammerAlert = false
                self.navigatorReceivedOpenHelp = false
                self.navigatorReceivedCloseAfterSignUp = false

                disposeBag = DisposeBag()
                featureFlags = MockFeatureFlags()
                sessionManager = MockSessionManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()

                let email = "albert@letgo.com"
                let myUser = MockMyUser()
                myUser.email = email
                sessionManager.signUpResult = SessionMyUserResult(value: myUser)
                sessionManager.logInResult = SessionMyUserResult(value: myUser)

                sut = SignUpEmailStep2ViewModel(email: email, isRememberedEmail: false, password: "654321",
                                                source: .sell, sessionManager: sessionManager,
                                                keyValueStorage: keyValueStorage,
                                                featureFlags: featureFlags, tracker: tracker)
                sut.signUpEnabled.subscribeNext { enabled in
                    signUpEnabled = enabled
                }.addDisposableTo(disposeBag)
                sut.delegate = self
                sut.navigator = self
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

            describe("sign up with invalid form") {
                var errors: SignUpEmailStep2FormErrors!

                context("username empty") {
                    beforeEach {
                        sut.username.value = ""
                        errors = sut.signUp()
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
                        errors = sut.signUp()
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
                        errors = sut.signUp()
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
                        errors = sut.signUp()
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
                    errors = sut.signUp()
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

                describe("sign up fails with user not verified error") {
                    beforeEach {
                        sessionManager.signUpResult = SessionMyUserResult(error: .userNotVerified)
                        _ = sut.signUp()

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
                        expect(self.navigatorReceivedOpenRecaptcha) == true
                    }
                }

                describe("sign up fails with conflict user exists error") {
                    beforeEach {
                        sessionManager.signUpResult = SessionMyUserResult(error: .conflict(cause: .userExists))
                    }

                    describe("auto log in fails") {
                        beforeEach {
                            sessionManager.logInResult = SessionMyUserResult(error: .network)
                            _ = sut.signUp()

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
                        let email = "albert@letgo.com"

                        beforeEach {
                            let myUser = MockMyUser()
                            myUser.email = email
                            sessionManager.logInResult = SessionMyUserResult(value: myUser)
                            _ = sut.signUp()

                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }

                        it("tracks a loginEmail event") {
                            let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmail]
                        }
                        it("calls close after signup in navigator when signup succeeds") {
                            expect(self.navigatorReceivedCloseAfterSignUp) == true
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
                        sessionManager.signUpResult = SessionMyUserResult(error: .network)
                        _ = sut.signUp()

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
                    let email = "albert@letgo.com"

                    beforeEach {
                        let myUser = MockMyUser()
                        myUser.email = email
                        sessionManager.signUpResult = SessionMyUserResult(value: myUser)
                        _ = sut.signUp()

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


extension SignUpEmailStep2ViewModelSpec: SignUpEmailStep2ViewModelDelegate {
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        completion?()
    }

    func vmShowLoading(_ loadingMessage: String?) {
        self.delegateReceivedShowLoading = true
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        self.delegateReceivedHideLoading = true
        afterMessageCompletion?()
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {}
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {}
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {}
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}

    func vmPop() {}
    func vmDismiss(_ completion: (() -> Void)?) {}

    func vmOpenInternalURL(_ url: URL) {}
}


extension SignUpEmailStep2ViewModelSpec: SignUpEmailStep2Navigator {
    func openHelpFromSignUpEmailStep2() {
        navigatorReceivedOpenHelp = true
    }

    func openRecaptchaFromSignUpEmailStep2() {
        navigatorReceivedOpenRecaptcha = true
    }

    func openScammerAlertFromSignUpEmailStep2() {
        navigatorReceivedOpenScammerAlert = true
    }

    func closeAfterSignUpSuccessful() {
        navigatorReceivedCloseAfterSignUp = true
    }
}
