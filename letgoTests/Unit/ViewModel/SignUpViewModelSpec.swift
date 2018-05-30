//
//  SignUpViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result


class SignUpViewModelSpec: QuickSpec {
    var loading: Bool = false
    var finishedSuccessfully: Bool = false
    var finishedScammer: Bool = false
    var finishedDeviceNotAllowed: Bool = false
    
    override func spec() {

        describe("SignUpViewModelSpec") {
            var sut: SignUpViewModel!
            var sessionManager: MockSessionManager!
            var installationRepository: MockInstallationRepository!
            var keyValueStorage: MockKeyValueStorage!
            var featureFlags: MockFeatureFlags!
            var tracker: MockTracker!
            var googleLoginHelper: MockExternalAuthHelper!
            var fbLoginHelper: MockExternalAuthHelper!

            beforeEach {
                sessionManager = MockSessionManager()
                installationRepository = MockInstallationRepository()
                keyValueStorage = MockKeyValueStorage()
                featureFlags = MockFeatureFlags()
                tracker = MockTracker()
                let myUser = MockMyUser.makeMock()
                googleLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                fbLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                sut = SignUpViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                    keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .dark,
                    source: .install, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
                sut.delegate = self
                sut.navigator = self

                self.loading = false
                self.finishedSuccessfully = false
                self.finishedScammer = false
                self.finishedDeviceNotAllowed = false
            }

            describe("initialization") {
                context("did not log in previously") {
                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("does not have a previous google username") {
                        expect(sut.previousGoogleUsername.value).to(beNil())
                    }
                }

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        sut = SignUpViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                            keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .dark,
                            source: .install, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
                    }

                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("does not have a previous google username") {
                        expect(sut.previousGoogleUsername.value).to(beNil())
                    }
                }

                context("previously logged in by facebook") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "facebook"
                        keyValueStorage[.previousUserEmailOrName] = "Albert FB"

                        sut = SignUpViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                            keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .dark,
                            source: .install, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
                    }

                    it("has a previous facebook username") {
                        expect(sut.previousFacebookUsername.value) == "Albert FB"
                    }
                    it("does not have a previous google username") {
                        expect(sut.previousGoogleUsername.value).to(beNil())
                    }
                }

                context("previously logged in by google") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "google"
                        keyValueStorage[.previousUserEmailOrName] = "Albert Google"

                        sut = SignUpViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                            keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .dark,
                            source: .install, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
                    }

                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("has a previous google username") {
                        expect(sut.previousGoogleUsername.value) == "Albert Google"
                    }
                }
            }

            describe("login with google") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        myUser = MockMyUser.makeMock()
                        myUser.name = "Albert"
                        googleLoginHelper.loginResult = .success(myUser: myUser)

                        sut.connectGoogleButtonPressed()
                        expect(self.loading).toEventually(beFalse())
                    }

                    it("saves google as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "google"
                    }
                    it("saves the user name as previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == myUser.name
                    }
                    it("tracks login-screen & login-google events") {
                        expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-google"]
                    }
                }

                context("error") {
                    context("standard") {
                        beforeEach {
                            googleLoginHelper.loginResult = .notFound
                            sut.connectGoogleButtonPressed()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks login-screen & login-signup-error-google events") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-google"]
                        }
                    }
                    context("scammer") {
                        beforeEach {
                            googleLoginHelper.loginResult = .scammer
                            sut.connectGoogleButtonPressed()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks login-screen & login-signup-error-google events") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-google"]
                        }
                        it("asks to show scammer error alert") {
                            expect(self.finishedScammer).to(beTrue())
                        }
                    }
                    context("device not allowed") {
                        beforeEach {
                            googleLoginHelper.loginResult = .deviceNotAllowed
                            sut.connectGoogleButtonPressed()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks login-screen & login-signup-error-google events") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-google"]
                        }
                        it("asks to show device not allowed error alert") {
                            expect(self.finishedDeviceNotAllowed).to(beTrue())
                        }
                    }
                }
            }

            describe("login with facebook") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        myUser = MockMyUser.makeMock()
                        myUser.name = "Albert"
                        fbLoginHelper.loginResult = .success(myUser: myUser)

                        sut.connectFBButtonPressed()
                        expect(self.loading).toEventually(beFalse())
                    }

                    it("saves google as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "facebook"
                    }
                    it("saves the user name as previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == myUser.name
                    }
                    it("tracks login-screen & login-fb events") {
                        expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-fb"]
                    }
                }

                context("error") {
                    context("standard") {
                        beforeEach {
                            fbLoginHelper.loginResult = .notFound
                            sut.connectFBButtonPressed()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks login-screen & login-signup-error-facebook events") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-facebook"]
                        }
                    }
                    context("scammer") {
                        beforeEach {
                            fbLoginHelper.loginResult = .scammer
                            sut.connectFBButtonPressed()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks login-screen & login-signup-error-facebook events") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-facebook"]
                        }
                        it("asks to show scammer error alert") {
                            expect(self.finishedScammer).to(beTrue())
                        }
                    }
                    context("device not allowed") {
                        beforeEach {
                            fbLoginHelper.loginResult = .deviceNotAllowed
                            sut.connectFBButtonPressed()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks login-screen & login-signup-error-facebook events") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-facebook"]
                        }
                        it("asks to show device not allowed error alert") {
                            expect(self.finishedDeviceNotAllowed).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}

extension SignUpViewModelSpec: MainSignUpNavigator {
    func cancelMainSignUp() {
        finishedSuccessfully = false
    }
    func closeMainSignUpSuccessful(with myUser: MyUser) {
        finishedSuccessfully = true
    }
    func closeMainSignUpAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        finishedSuccessfully = false
        finishedScammer = true
    }
    func closeMainSignUpAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        finishedSuccessfully = false
        finishedDeviceNotAllowed = true
    }
    func openSignUpEmailFromMainSignUp() {}
    func openLogInEmailFromMainSignUp() {}

    func openHelpFromMainSignUp() {}
    func open(url: URL) {}
}

extension SignUpViewModelSpec: SignUpViewModelDelegate {

    // BaseViewModelDelegate
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {}
    func vmShowAutoFadingMessage(title: String, message: String, time: Double, completion: (() -> ())?) {}
    func vmShowLoading(_ loadingMessage: String?) {
        loading = true
    }
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        loading = false
        afterMessageCompletion?()
    }
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {}
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {}
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?, dismissAction: (() -> ())?) {}
    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?, dismissAction: (() -> ())?) {}
    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {}
    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func vmPop() {}
    func vmDismiss(_ completion: (() -> Void)?){}
    func vmOpenInAppWebViewWith(url: URL) {}
}
