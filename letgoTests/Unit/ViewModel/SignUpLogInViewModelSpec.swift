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
                let myUser = MockMyUser.makeMock()
                googleLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                fbLoginHelper = MockExternalAuthHelper(result: .success(myUser: myUser))
                let locale = Locale(identifier: "es_ES")

                sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository: installationRepository,
                    locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                    fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                    locale: locale, source: .install, collapsedEmailParam: nil, action: .signup)
                sut.delegate = self
                sut.navigator = self

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

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        let locale = Locale(identifier: "es_ES")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale, source: .install, collapsedEmailParam: nil, action: .signup)
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

                        let locale = Locale(identifier: "es_ES")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, collapsedEmailParam: nil, action: .signup)
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

                        let locale = Locale(identifier: "es_ES")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, collapsedEmailParam: nil, action: .signup)
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

                context("phone locale is in Turkey") {
                    beforeEach {
                        let locale = Locale(identifier: "tr_TR")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, collapsedEmailParam: nil, action: .signup)
                    }

                    it("has terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == true
                    }
                }

                context("current postal address's country code is Turkey") {
                    beforeEach {
                        let locale = Locale(identifier: "es_ES")
                        locationManager.currentLocation = LGLocation(latitude: 12.00, longitude: 34.03, type: .sensor, postalAddress: PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "tr", country: ""))
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, collapsedEmailParam: nil, action: .signup)
                    }

                    it("has terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == true
                    }
                }

                context("phone locale and location are not in Turkey") {
                    beforeEach {
                        let locale = Locale(identifier: "es_ES")
                        locationManager.currentLocation = LGLocation(latitude: 12.00, longitude: 34.03, type: .sensor, postalAddress: PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "es", country: ""))
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, collapsedEmailParam: nil, action: .signup)
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

                        myUser = MockMyUser.makeMock()
                        myUser.email = email
                        sessionManager.logInResult = SessionMyUserResult(value: myUser)

                        sut.email = email
                        sut.password = "123456"

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

                context("error") {
                    context("standard") {
                        beforeEach {
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = SessionMyUserResult(error: .network)

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
                            sessionManager.logInResult = SessionMyUserResult(error: .scammer)

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
                        myUser = MockMyUser.makeMock()
                        myUser.name = "Albert"

                        googleLoginHelper.loginResult = .success(myUser: myUser)

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

                context("error") {
                    context("standard") {
                        beforeEach {
                            googleLoginHelper.loginResult = .notFound
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
                            googleLoginHelper.loginResult = .scammer
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
                        myUser = MockMyUser.makeMock()
                        myUser.name = "Albert"

                        fbLoginHelper.loginResult = .success(myUser: myUser)

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

                context("error") {
                    context("standard") {
                        beforeEach {
                            fbLoginHelper.loginResult = .notFound
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
                            fbLoginHelper.loginResult = .scammer
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

extension SignUpLogInViewModelSpec: SignUpLogInNavigator {
    func cancelSignUpLogIn() {
        finishedSuccessfully = false
    }
    func closeSignUpLogInSuccessful(with myUser: MyUser) {
        finishedSuccessfully = true
    }
    func closeSignUpLogInAndOpenScammerAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        finishedSuccessfully = false
        finishedScammer = true
    }
    func openRecaptcha(transparentMode: Bool) {}

    func openRememberPasswordFromSignUpLogIn(email: String?) {}
    func openHelpFromSignUpLogin() {}
    func open(url: URL) {}
}

extension SignUpLogInViewModelSpec: SignUpLogInViewModelDelegate {
    func vmUpdateSendButtonEnabledState(_ enabled: Bool) {}
    func vmUpdateShowPasswordVisible(_ visible: Bool) {}
    func vmShowHiddenPasswordAlert() {}

    // BaseViewModelDelegate
    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {}
    func vmShowLoading(_ loadingMessage: String?) {
        loading = true
    }
    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        loading = false
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
    func vmDismiss(_ completion: (() -> Void)?){}
    func vmOpenInternalURL(_ url: URL) {}
}
