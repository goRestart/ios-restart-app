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

    override func spec() {
        describe("SignUpLogInViewModelSpec") {
            var sut: SignUpLogInViewModel!

            var sessionManager: MockSessionManager!
            var locationManager: MockLocationManager!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!
            var googleLoginHelper: MockExternalAuthHelper!
            var fbLoginHelper: MockExternalAuthHelper!

            beforeEach {
                sessionManager = MockSessionManager()
                locationManager = MockLocationManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                let myUser = MockMyUser()
                googleLoginHelper = MockExternalAuthHelper(result: .Success(myUser: myUser))
                fbLoginHelper = MockExternalAuthHelper(result: .Success(myUser: myUser))
                let locale = NSLocale(localeIdentifier: "es_ES")

                sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                    keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                    fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
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

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        let locale = NSLocale(localeIdentifier: "es_ES")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
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
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
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
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
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
                        let locale = NSLocale(localeIdentifier: "tr_TR")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
                    }

                    it("has terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == true
                    }
                }

                context("current postal address's country code is Turkey") {
                    beforeEach {
                        let locale = NSLocale(localeIdentifier: "es_ES")
                        locationManager.currentPostalAddress = PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "tr", country: "")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
                    }

                    it("has terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == true
                    }
                }

                context("phone locale and location are not in Turkey") {
                    beforeEach {
                        let locale = NSLocale(localeIdentifier: "es_ES")
                        locationManager.currentPostalAddress = PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "es", country: "")

                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, locale: locale, source: .Install, action: .Signup)
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
            }

            describe("login with google") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        myUser = MockMyUser()
                        myUser.name = "Albert"

                        googleLoginHelper.loginResult = .Success(myUser: myUser)
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
                    beforeEach {
                        googleLoginHelper.loginResult = .Forbidden
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
            }

            describe("login with facebook") {
                context("successful") {
                    var myUser: MockMyUser!

                    beforeEach {
                        myUser = MockMyUser()
                        myUser.name = "Albert"

                        fbLoginHelper.loginResult = .Success(myUser: myUser)
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
                    beforeEach {
                        fbLoginHelper.loginResult = .Forbidden
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
            }
        }
    }
}

extension SignUpLogInViewModelSpec: SignUpLogInViewModelDelegate {
    // visual
    func viewModel(viewModel: SignUpLogInViewModel, updateSendButtonEnabledState enabled: Bool) {

    }

    func viewModel(viewModel: SignUpLogInViewModel, updateShowPasswordVisible visible: Bool) {

    }
    func viewModelShowHiddenPasswordAlert(viewModel: SignUpLogInViewModel) {

    }
    func viewModelShowGodModeError(viewModel: SignUpLogInViewModel) {

    }

    // signup
    func viewModelDidStartSigningUp(viewModel: SignUpLogInViewModel) {
        loading = true
    }
    func viewModelDidSignUp(viewModel: SignUpLogInViewModel) {
        loading = false
        finishedSuccessfully = true
    }
    func viewModelDidFailSigningUp(viewModel: SignUpLogInViewModel, message: String) {
        loading = false
        finishedSuccessfully = false
    }
    func viewModelShowRecaptcha(viewModel: RecaptchaViewModel) {

    }

    // login
    func viewModelDidStartLoginIn(viewModel: SignUpLogInViewModel) {
        loading = true
    }
    func viewModelDidLogIn(viewModel: SignUpLogInViewModel) {
        loading = false
        finishedSuccessfully = true
    }
    func viewModelDidFailLoginIn(viewModel: SignUpLogInViewModel, message: String) {
        loading = false
        finishedSuccessfully = false
    }

    // fb login
    func viewModelDidStartAuthWithExternalService(viewModel: SignUpLogInViewModel) {
        loading = true
    }
    func viewModelDidAuthWithExternalService(viewModel: SignUpLogInViewModel) {
        loading = false
        finishedSuccessfully = true
    }
    func viewModelDidCancelAuthWithExternalService(viewModel: SignUpLogInViewModel) {
        loading = false
        finishedSuccessfully = false
    }
    func viewModel(viewModel: SignUpLogInViewModel, didFailAuthWithExternalService message: String) {
        loading = false
        finishedSuccessfully = false
    }
}
