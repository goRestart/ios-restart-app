//
//  SignUpViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result


class SignUpViewModelSpec: QuickSpec {
    var loading: Bool = false
    var finishedSuccessfully: Bool = false
    var finishedScammer: Bool = false
    
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
                let myUser = MockMyUser()
                googleLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                fbLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                sut = SignUpViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                    keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .Dark,
                    source: .install, googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
                sut.delegate = self

                self.loading = false
                self.finishedSuccessfully = false
                self.finishedScammer = false
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
                            keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .Dark,
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
                            keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .Dark,
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
                            keyValueStorage: keyValueStorage, featureFlags: featureFlags, tracker: tracker, appearance: .Dark,
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
                        myUser = MockMyUser()
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
                }
            }

            describe("login with facebook") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        myUser = MockMyUser()
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
                }
            }
        }
    }
}

extension SignUpViewModelSpec: SignUpViewModelDelegate {

    func vmOpenSignup(viewModel: SignUpLogInViewModel) {}

    func vmFinish(completedLogin completed: Bool) {
        finishedSuccessfully = completed
    }

    func vmFinishAndShowScammerAlert(contactUrl: URL, network: EventParameterAccountNetwork, tracker: Tracker) {
        finishedSuccessfully = false
        finishedScammer = true
    }


    // BaseViewModelDelegate
    func vmShowAutoFadingMessage(message: String, completion: (() -> ())?) {}
    func vmShowLoading(loadingMessage: String?) {
        loading = true
    }
    func vmHideLoading(finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        loading = false
        afterMessageCompletion?()
    }
    func vmShowAlertWithTitle(title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {}
    func vmShowAlertWithTitle(title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {}
    func vmShowAlert(title: String?, message: String?, actions: [UIAction]) {}
    func vmShowAlert(title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {}
    func vmShowActionSheet(cancelAction: UIAction, actions: [UIAction]) {}
    func vmShowActionSheet(cancelLabel: String, actions: [UIAction]) {}
    func ifLoggedInThen(source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {}
    func ifLoggedInThen(source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: () -> Void) {}
    func vmPop() {}
    func vmDismiss(completion: (() -> Void)?){}
    func vmOpenInternalURL(url: URL) {}
}
