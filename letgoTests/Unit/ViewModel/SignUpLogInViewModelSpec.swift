//
//  SignUpLogInViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result


class SignUpLogInViewModelSpec: QuickSpec {
    var loading: Bool = false
    var finishedSuccessfully: Bool = false
    var finishedScammer: Bool = false

    override func spec() {
        describe("SignUpLogInViewModelSpec") {
            var sut: SignUpLogInViewModel!

            var sessionManager: MockSessionManager!
            var installationRepository: MockInstallationRepository!
            var locationManager: MockLocationManager!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!
            var featureFlags: MockFeatureFlags!
            var googleLoginHelper: MockExternalAuthHelper!
            var fbLoginHelper: MockExternalAuthHelper!

            beforeEach {
                sessionManager = MockSessionManager()
                installationRepository = MockInstallationRepository()
                locationManager = MockLocationManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                featureFlags = MockFeatureFlags()
                let myUser = MockMyUser()
                googleLoginHelper = MockExternalAuthHelper(result: .Success(myUser: myUser))
                fbLoginHelper = MockExternalAuthHelper(result: .Success(myUser: myUser))
                let locale = NSLocale(localeIdentifier: "es_ES")

                sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                    locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                    fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                    locale: locale, source: .Install, action: .Signup)
                sut.delegate = self

                self.loading = false
                self.finishedSuccessfully = false
            }

            describe("initialization") {
                context("common") {
                    it("has an empty username") {
                        expect(sut.username) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password) == ""
                    }
                }

                context("did not log in previously") {
                    it("has an empty email") {
                        expect(sut.email) == ""
                    }
                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("does not have a previous google username") {
                        expect(sut.previousGoogleUsername.value).to(beNil())
                    }
                }

                context("AB test saveMailLogout enabled") {
                    beforeEach {
                        featureFlags.saveMailLogout = true
                    }

                    context("previously logged in by email") {
                        beforeEach {
                            keyValueStorage[.previousUserAccountProvider] = "letgo"
                            keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                            let locale = NSLocale(localeIdentifier: "es_ES")
                            sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                                locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                                fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                                locale: locale, source: .Install, action: .Signup)
                        }

                        it("has an email") {
                            expect(sut.email) == "albert@letgo.com"
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

                            let locale = NSLocale(localeIdentifier: "es_ES")
                            sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                                locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                                fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                                locale: locale, source: .Install, action: .Signup)
                        }

                        it("has an empty email") {
                            expect(sut.email) == ""
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

                            let locale = NSLocale(localeIdentifier: "es_ES")
                            sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                                locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                                fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                                locale: locale, source: .Install, action: .Signup)
                        }

                        it("has an empty email") {
                            expect(sut.email) == ""
                        }
                        it("does not have a previous facebook username") {
                            expect(sut.previousFacebookUsername.value).to(beNil())
                        }
                        it("has a previous google username") {
                            expect(sut.previousGoogleUsername.value) == "Albert Google"
                        }
                    }
                }

                context("AB test saveMailLogout disabled") {
                    beforeEach {
                        featureFlags.saveMailLogout = false

                        let locale = NSLocale(localeIdentifier: "es_ES")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale, source: .Install, action: .Signup)
                    }

                    it("has an empty email") {
                        expect(sut.email) == ""
                    }
                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("does not have a previous google username") {
                        expect(sut.previousGoogleUsername.value).to(beNil())
                    }
                }


                context("phone locale is in Turkey") {
                    beforeEach {
                        let locale = NSLocale(localeIdentifier: "tr_TR")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale, source: .Install, action: .Signup)
                    }

                    it("has terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == true
                    }
                }

                context("current postal address's country code is Turkey") {
                    beforeEach {
                        let locale = NSLocale(localeIdentifier: "es_ES")
                        locationManager.currentPostalAddress = PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "tr", country: "")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale, source: .Install, action: .Signup)
                    }

                    it("has terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == true
                    }
                }

                context("phone locale and location are not in Turkey") {
                    beforeEach {
                        let locale = NSLocale(localeIdentifier: "es_ES")
                        locationManager.currentPostalAddress = PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "es", country: "")

                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale, source: .Install, action: .Signup)
                    }

                    it("has terms and conditions false") {
                        expect(sut.termsAndConditionsEnabled) == false
                    }
                }

            }

            describe("login with email") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        let email = "albert@letgo.com"

                        myUser = MockMyUser()
                        myUser.email = email
                        sessionManager.myUserResult = SessionMyUserResult(value: myUser)

                        sut.email = email
                        sut.password = "123456"
                    }

                    context("AB test saveMailLogout enabled") {
                        beforeEach {
                            featureFlags.saveMailLogout = true

                            sut.logIn()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("saves letgo as previous user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider) == "letgo"
                        }
                        it("saves the user email as previous email") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username) == myUser.email
                        }
                        it("tracks a login-email event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-email"]
                        }
                    }

                    context("AB test saveMailLogout disabled") {
                        beforeEach {
                            featureFlags.saveMailLogout = false

                            sut.logIn()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save any user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save any previous user email or name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks a login-email event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-email"]
                        }
                    }
                }

                context("error") {
                    context("standard") {
                        beforeEach {
                            let email = "albert@letgo.com"
                            sessionManager.myUserResult = SessionMyUserResult(error: .Network)

                            sut.email = email
                            sut.password = "123456"
                            sut.logIn()
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
                        it("tracks a login-error event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-error"]
                        }
                    }
                    context("scammer") {
                        beforeEach {
                            let email = "albert@letgo.com"
                            sessionManager.myUserResult = SessionMyUserResult(error: .Scammer)

                            sut.email = email
                            sut.password = "123456"
                            sut.logIn()
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
                        it("tracks a login-error event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-error"]
                        }
                        it("asks to show scammer error alert") {
                            expect(self.finishedScammer).to(beTrue())
                        }
                    }
                }
            }

            describe("login with google") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        myUser = MockMyUser()
                        myUser.name = "Albert"

                        googleLoginHelper.loginResult = .Success(myUser: myUser)
                    }

                    context("AB test saveMailLogout enabled") {
                        beforeEach {
                            featureFlags.saveMailLogout = true

                            sut.logInWithGoogle()
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
                        it("tracks a login-google event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-google"]
                        }
                    }

                    context("AB test saveMailLogout disabled") {
                        beforeEach {
                            featureFlags.saveMailLogout = false

                            sut.logInWithGoogle()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save any user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save any previous user email or name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks a login-google event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-google"]
                        }
                    }
                }

                context("error") {
                    context("standard") {
                        beforeEach {
                            googleLoginHelper.loginResult = .NotFound
                            sut.logInWithGoogle()
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
                        it("tracks a login-signup-error-google event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-signup-error-google"]
                        }
                    }
                    context("scammer") {
                        beforeEach {
                            googleLoginHelper.loginResult = .Scammer
                            sut.logInWithGoogle()
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
                        it("tracks a login-signup-error-google event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-signup-error-google"]
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

                        fbLoginHelper.loginResult = .Success(myUser: myUser)
                    }

                    context("AB test saveMailLogout enabled") {
                        beforeEach {
                            featureFlags.saveMailLogout = true

                            sut.logInWithFacebook()
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
                        it("tracks a login-fb event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-fb"]
                        }
                    }

                    context("AB test saveMailLogout disabled") {
                        beforeEach {
                            featureFlags.saveMailLogout = false

                            sut.logInWithFacebook()
                            expect(self.loading).toEventually(beFalse())
                        }

                        it("does not save any user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save any previous user email or name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("tracks a login-fb event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-fb"]
                        }
                    }
                }

                context("error") {
                    context("standard") {
                        beforeEach {
                            fbLoginHelper.loginResult = .NotFound
                            sut.logInWithFacebook()
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
                        it("tracks a login-signup-error-facebook event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-signup-error-facebook"]
                        }
                    }
                    context("scammer") {
                        beforeEach {
                            fbLoginHelper.loginResult = .Scammer
                            sut.logInWithFacebook()
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
                        it("tracks a login-signup-error-facebook event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-signup-error-facebook"]
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

extension SignUpLogInViewModelSpec: SignUpLogInViewModelDelegate {

    func vmUpdateSendButtonEnabledState(enabled: Bool) {}
    func vmUpdateShowPasswordVisible(visible: Bool) {}
    func vmFinish(completedAccess completed: Bool) {
        finishedSuccessfully = completed
    }
    func vmFinishAndShowScammerAlert(contactUrl: NSURL, network: EventParameterAccountNetwork, tracker: Tracker) {
        finishedSuccessfully = false
        finishedScammer = true
    }
    func vmShowRecaptcha(viewModel: RecaptchaViewModel) {}
    func vmShowHiddenPasswordAlert() {}

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
}
