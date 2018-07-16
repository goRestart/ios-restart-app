//
//  SignUpLogInViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift

class SignUpLogInViewModelSpec: BaseViewModelSpec {
    var finishedSuccessfully: Bool = false
    var finishedScammer: Bool = false
    var finishedDeviceNotAllowed: Bool = false
    var openRecaptchaCalled: Bool = false
    
    var delegateReceivedShowGodModeAlert = false
    var navigatorReceivedOpenRememberPassword = false
    var navigatorReceivedOpenHelp = false

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
            
            var sendButtonEnabled: Bool!
            var disposeBag: DisposeBag!
            
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
                    keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                    fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                    locale: locale, source: .install, action: .signup)
                sut.delegate = self
                sut.navigator = self

                self.finishedSuccessfully = false
                self.finishedScammer = false
                self.finishedDeviceNotAllowed = false
                self.openRecaptchaCalled = false
                
                self.delegateReceivedShowGodModeAlert = false
                self.delegateReceivedHideLoading = false
                self.delegateReceivedShowAlert = false
                self.navigatorReceivedOpenRememberPassword = false
                self.navigatorReceivedOpenHelp = false
                
                sendButtonEnabled = false
                disposeBag = DisposeBag()
                sut.sendButtonEnabled.subscribeNext { enabled in
                    sendButtonEnabled = enabled
                }.disposed(by: disposeBag)
            }

            describe("initialization") {
                context("common") {
                    it("has an empty username") {
                        expect(sut.username.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("maps feature flags' terms and conditions enabled") {
                        expect(sut.termsAndConditionsEnabled) == featureFlags.signUpEmailTermsAndConditionsAcceptRequired
                    }
                }

                context("did not log in previously") {
                    it("has an empty email") {
                        expect(sut.email.value) == ""
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
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale, source: .install, action: .signup)
                    }

                    it("has an email") {
                        expect(sut.email.value) == "albert@letgo.com"
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
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, action: .signup)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
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
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, action: .signup)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("has a previous google username") {
                        expect(sut.previousGoogleUsername.value) == "Albert Google"
                    }
                }

                context("phone locale and location are not in Turkey") {
                    beforeEach {
                        let locale = Locale(identifier: "es_ES")
                        locationManager.currentLocation = LGLocation(latitude: 12.00, longitude: 34.03, type: .sensor, postalAddress: PostalAddress(address: "", city: "", zipCode: "", state: "", countryCode: "es", country: ""))
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, action: .signup)
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
                        sessionManager.logInResult = LoginResult(value: myUser)

                        sut.currentActionType = .login
                        sut.email.value = email
                        sut.password.value = "123456"

                        sut.logIn()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            sut.currentActionType = .login
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = LoginResult(error: .network)

                            sut.email.value = email
                            sut.password.value = "123456"
                            sut.currentActionType = .login
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            sut.currentActionType = .login
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = LoginResult(error: .scammer)

                            sut.email.value = email
                            sut.password.value = "123456"
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.finishedScammer).toEventually(beTrue())
                        }
                    }
                    context("device not allowed") {
                        beforeEach {
                            sut.currentActionType = .login
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = LoginResult(error: .deviceNotAllowed)

                            sut.email.value = email
                            sut.password.value = "123456"
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                        it("asks to show device not allowed error alert") {
                            expect(self.finishedDeviceNotAllowed).toEventually(beTrue())
                        }
                    }
                    context("user not verified") {
                        beforeEach {
                            sut.currentActionType = .login
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = LoginResult(error: .userNotVerified)
                            
                            sut.email.value = email
                            sut.password.value = "123456"
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("does not track a login-error event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == []
                        }
                        it("asks to open recaptcha") {
                            expect(self.openRecaptchaCalled).toEventually(beTrue())
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
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.finishedScammer).toEventually(beTrue())
                        }
                    }
                    context("device not allowed") {
                        beforeEach {
                            googleLoginHelper.loginResult = .deviceNotAllowed
                            sut.logInWithGoogle()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                        it("asks to show device not allowed error alert") {
                            expect(self.finishedDeviceNotAllowed).toEventually(beTrue())
                        }
                    }
                    context("user not verified") {
                        beforeEach {
                            sut.currentActionType = .login
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = LoginResult(error: .userNotVerified)
                            
                            sut.email.value = email
                            sut.password.value = "123456"
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("does not track a login-error event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == []
                        }
                        it("asks to open recaptcha") {
                            expect(self.openRecaptchaCalled).toEventually(beTrue())
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
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                            expect(self.finishedScammer).toEventually(beTrue())
                        }
                    }
                    context("device not allowed") {
                        beforeEach {
                            fbLoginHelper.loginResult = .deviceNotAllowed
                            sut.logInWithFacebook()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
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
                        it("asks to show device not allowed error alert") {
                            expect(self.finishedDeviceNotAllowed).toEventually(beTrue())
                        }
                    }
                    context("user not verified") {
                        beforeEach {
                            sut.currentActionType = .login
                            let email = "albert@letgo.com"
                            sessionManager.logInResult = LoginResult(error: .userNotVerified)
                            
                            sut.email.value = email
                            sut.password.value = "123456"
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("does not save a user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider).to(beNil())
                        }
                        it("does not save a previous user name") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username).to(beNil())
                        }
                        it("does not track a login-error event") {
                            expect(tracker.trackedEvents.map({ $0.actualName })) == []
                        }
                        it("asks to open recaptcha") {
                            expect(self.openRecaptchaCalled).toEventually(beTrue())
                        }
                    }
                }
            }
            
            describe("log in with email") {
                describe("form validation") {
                    
                    var logInEmailForm: LogInEmailForm!
                    var errors: LogInEmailFormErrors!
                    
                    beforeEach {
                        sut.currentActionType = .login
                        errors = []
                    }
                    
                    context("empty") {
                        beforeEach {
                            logInEmailForm = LogInEmailForm(email: "", password: "")
                            errors = logInEmailForm.checkErrors()
                        }
                        it("returns invalid email & short password") {
                            expect(errors) == [.invalidEmail, .shortPassword]
                        }
                    }
                    
                    context("with email non-valid") {
                        beforeEach {
                            logInEmailForm = LogInEmailForm(email: "a",
                                                            password: "pwdUltr4way")
                            errors = logInEmailForm.checkErrors()
                        }
                        it("returns that the email is invalid") {
                            expect(errors) == [.invalidEmail]
                        }
                    }

                    context("with short password") {
                        beforeEach {
                            logInEmailForm = LogInEmailForm(email: "legit@email.com",
                                                            password: "a")
                            errors = logInEmailForm.checkErrors()
                        }
                        it("returns that the password is short") {
                            expect(errors) == [.shortPassword]
                        }
                    }

                    context("with email non-valid & short password") {
                        beforeEach {
                            logInEmailForm = LogInEmailForm(email: "a",
                                                            password: "b")
                            errors = logInEmailForm.checkErrors()
                        }
                        it("returns that the email is invalid") {
                            expect(errors) == [.invalidEmail, .shortPassword]
                        }
                    }

                    context("with valid email & password") {
                        beforeEach {
                            logInEmailForm = LogInEmailForm(email: "albert@letgo.com",
                                                            password: "letitgo")
                            errors = logInEmailForm.checkErrors()
                        }
                        it("returns no errors") {
                            expect(errors) == []
                        }
                    }
                }
                
                describe("log in process") {
                    beforeEach {
                        sut.currentActionType = .login
                    }
                    context("empty") {
                        beforeEach {
                            sut.email.value = ""
                            sut.password.value = ""
                            sut.logIn()
                        }

                        it("send button is not enabled") {
                            expect(sendButtonEnabled) == false
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("does not track any event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == []
                        }
                    }
                    context("with email non-valid") {
                        beforeEach {
                            sut.email.value = "a"
                            sut.password.value = "abcd"
                            sut.logIn()
                        }
                        
                        it("has send button enabled") {
                            expect(sendButtonEnabled) == true
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError]
                        }
                        it("shows error message") {
                            expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                        }
                    }
                    context("with short password") {
                        beforeEach {
                            sut.email.value = "legit@email.com"
                            sut.password.value = "a"
                            sut.logIn()
                        }

                        it("has send button enabled") {
                            expect(sendButtonEnabled) == true
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError]
                        }
                        it("shows error message") {
                            expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                        }
                    }
                    context("with valid email & password") {
                        beforeEach {
                            sut.email.value = "albert@letgo.com"
                            sut.password.value = "letitgo"
                            sut.logIn()
                        }
                        
                        it("has send button enabled") {
                            expect(sendButtonEnabled) == true
                        }
                        it("does not track any event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == []
                        }
                    }
                }
                
                describe("tracking") {
                    beforeEach {
                        sut.currentActionType = .login
                    }
                    
                    context("empty") {
                        beforeEach {
                            sut.email.value = ""
                            sut.password.value = ""
                            sut.logIn()
                        }
                        
                        it("does not track any event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == []
                        }
                    }
                    
                    context("with email non-valid & short password") {
                        beforeEach {
                            sut.email.value = "a"
                            sut.password.value = "a"
                            sut.logIn()
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError]
                        }
                    }
                    
                    context("with valid email & password") {
                        beforeEach {
                            sut.email.value = "albert@letgo.com"
                            sut.password.value = "letitgo"
                            sut.logIn()
                        }
                        
                        it("does not track any event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == []
                        }
                    }
                }
                
                describe("send log in") {
                    beforeEach {
                        sut.currentActionType = .login
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "letitgo"
                    }
                    
                    context("log in fails once with unauthorized error") {
                        beforeEach {
                            sessionManager.logInResult = LoginResult(error: .unauthorized)
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("does not call show alert in the delegate to suggest reset pwd") {
                            expect(self.delegateReceivedShowAlert) == false
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("log in fails twice with unauthorized error") {
                        beforeEach {
                            sessionManager.logInResult = LoginResult(error: .unauthorized)
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                            self.delegateReceivedHideLoading = false
                            
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks two loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("calls show alert in the delegate to suggest reset pwd") {
                            expect(self.delegateReceivedShowAlert).toEventually(beTrue())
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("log in fails twice with another error") {
                        beforeEach {
                            sessionManager.logInResult = LoginResult(error: .network)
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                            self.delegateReceivedHideLoading = false
                            sut.logIn()
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks two loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("does not call show alert in the delegate to suggest reset pwd") {
                            expect(self.delegateReceivedShowAlert) == false
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("log in fails with scammer error") {
                        beforeEach {
                            sessionManager.logInResult = LoginResult(error: .scammer)
                            sut.logIn()
                            
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("calls open scammer alert in the navigator") {
                            expect(self.finishedScammer).toEventually(beTrue())
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("log in fails with device not allowed error") {
                        beforeEach {
                            sessionManager.logInResult = LoginResult(error: .deviceNotAllowed)
                            sut.logIn()
                            
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmailError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("calls open device not allowed alert in the navigator") {
                            expect(self.finishedDeviceNotAllowed).toEventually(beTrue())
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("log in succeeds") {
                        let email = "albert.hernandez@gmail.com"
                        
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.email = email
                            sessionManager.logInResult = LoginResult(value: myUser)
                            sut.logIn()
                            
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a loginEmail event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.loginEmail]
                        }
                        it("calls close after login in navigator when signup succeeds") {
                            expect(self.finishedSuccessfully).toEventually(beTrue())
                        }
                        it("saves letgo as previous user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider) == "letgo"
                        }
                        it("saves the user email as previous email") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username) == email
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                }
            }
            
            describe("sign up") {
                describe("form validation") {
                    
                    var signUpForm: SignUpForm!
                    var errors: SignUpFormErrors!
                    
                    beforeEach {
                        sut.currentActionType = .signup
                        errors = []
                    }
                    
                    context("empty") {
                        beforeEach {
                            signUpForm = SignUpForm(username: "",
                                                    email: "",
                                                    password: "",
                                                    termsAndConditionsEnabled: true,
                                                    termsAccepted: false)
                            errors = signUpForm.checkErrors()
                        }
                        
                        it("returns that the email is invalid, the password is short, the user is invalid and the terms are not accepted") {
                            expect(errors) == [.invalidEmail, .shortPassword, .invalidUsername, .termsNotAccepted]
                        }
                    }
                    
                    context("invalid username, invalid email, invalid password and terms not accepted") {
                        beforeEach {
                            signUpForm = SignUpForm(username: "a",
                                                    email: "a",
                                                    password: "a",
                                                    termsAndConditionsEnabled: true,
                                                    termsAccepted: false)
                            errors = signUpForm.checkErrors()
                        }
                        
                        it("returns that the email is invalid, the password is short, the user is invalid and the terms are not accepted") {
                            expect(errors) == [.invalidEmail, .shortPassword, .invalidUsername, .termsNotAccepted]
                        }
                    }
                    
                    context("valid username, valid email, long password and terms accepted") {
                        beforeEach {
                            signUpForm = SignUpForm(username: "albert",
                                                    email: "albert@letgo.com",
                                                    password: "abcdefghijklmnopqrstuvwxyz",
                                                    termsAndConditionsEnabled: true,
                                                    termsAccepted: true)
                            errors = signUpForm.checkErrors()
                        }
                        
                        it("returns that the password is long") {
                            expect(errors) == [.longPassword]
                        }
                    }
                    
                    context("with valid email, password, username and terms accepted") {
                        beforeEach {
                            signUpForm = SignUpForm(username: "albert",
                                                    email: "albert@letgo.com",
                                                    password: "letitgo",
                                                    termsAndConditionsEnabled: true,
                                                    termsAccepted: true)
                            errors = signUpForm.checkErrors()
                        }
                        
                        it("returns no errors") {
                            expect(errors) == []
                        }
                    }
                }
                
                describe("sign up process") {
                    beforeEach {
                        sut.currentActionType = .signup
                    }
                    
                    context("empty") {
                        beforeEach {
                            sut.email.value = ""
                            sut.password.value = ""
                            sut.username.value = ""
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("has send button disabled") {
                            expect(sendButtonEnabled) == false
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                    }
                    
                    context("with email non-valid & short password") {
                        beforeEach {
                            sut.email.value = "a"
                            sut.password.value = "a"
                            sut.username.value = "a"
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("has send button enabled") {
                            expect(sendButtonEnabled) == true
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("shows error message") {
                            expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                        }
                    }

                    context("with valid email, valid username but long password") {
                        beforeEach {
                            sut.email.value = "albert@letgo.com"
                            sut.password.value = "abcdefghijklmnopqrstuvwxyz"
                            sut.username.value = "albert"
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("has send button enabled") {
                            expect(sendButtonEnabled) == true
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("shows error message") {
                            expect(self.delegateReceivedShowAutoFadingMessage).toEventually(beTrue())
                        }
                    }
                    
                    context("with valid email, password and username") {
                        beforeEach {
                            sut.email.value = "albert@letgo.com"
                            sut.password.value = "letitgo"
                            sut.username.value = "albert"
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("has send button enabled") {
                            expect(sendButtonEnabled) == true
                        }
                    }
                }
                
                describe("tracking") {
                    beforeEach {
                        sut.currentActionType = .signup
                    }
                    
                    context("empty") {
                        beforeEach {
                            sut.email.value = ""
                            sut.password.value = ""
                            sut.username.value = ""
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("does not track any event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == []
                        }
                    }
                    
                    context("with email non-valid & short password") {
                        beforeEach {
                            sut.email.value = "a"
                            sut.password.value = "a"
                            sut.username.value = "a"
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("tracks a signupError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError]
                        }
                    }
                    
                    context("with valid email, valid username but long password") {
                        beforeEach {
                            sut.email.value = "albert@letgo.com"
                            sut.password.value = "abcdefghijklmnopqrstuvwxyz"
                            sut.username.value = "albert"
                            sut.signUp(recaptchaToken: nil)
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError]
                        }
                    }
                    
                    context("with valid email, password and username") {
                        beforeEach {
                            sut.email.value = "albert@letgo.com"
                            sut.password.value = "letitgo"
                            sut.username.value = "albert"
                            sut.signUp(recaptchaToken: nil)
                        }

                        it("does not track any event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == []
                        }
                    }
                }

                describe("send sign up") {
                    beforeEach {
                        sut.currentActionType = .signup
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "letitgo"
                        sut.username.value = "albert"
                    }
                    
                    context("sign up fails once with unauthorized error") {
                        beforeEach {
                            sessionManager.signUpResult = SignupResult(error: .unauthorized)
                            sut.signUp(recaptchaToken: nil)
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("does not call show alert in the delegate to suggest reset pwd") {
                            expect(self.delegateReceivedShowAlert) == false
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("sign up fails twice with unauthorized error") {
                        beforeEach {
                            sessionManager.signUpResult = SignupResult(error: .unauthorized)
                            sut.signUp(recaptchaToken: nil)
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                            self.delegateReceivedHideLoading = false
                            
                            sut.signUp(recaptchaToken: nil)
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks two signupError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError, EventName.signupError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("sign up fails twice with another error") {
                        beforeEach {
                            sessionManager.signUpResult = SignupResult(error: .network)
                            sut.signUp(recaptchaToken: nil)
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                            self.delegateReceivedHideLoading = false
                            sut.signUp(recaptchaToken: nil)
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks two loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError, EventName.signupError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("does not call show alert in the delegate to suggest reset pwd") {
                            expect(self.delegateReceivedShowAlert) == false
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("sign up fails with scammer error") {
                        beforeEach {
                            sessionManager.signUpResult = SignupResult(error: .scammer)
                            sut.signUp(recaptchaToken: nil)
                            
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a loginEmailError event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupError]
                        }
                        it("does not call close after login in navigator") {
                            expect(self.finishedSuccessfully) == false
                        }
                        it("calls open scammer alert in the navigator") {
                            expect(self.finishedScammer).toEventually(beTrue())
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                    
                    context("sign up succeeds") {
                        let email = "albert.hernandez@gmail.com"
                        
                        beforeEach {
                            var myUser = MockMyUser.makeMock()
                            myUser.email = email
                            sessionManager.signUpResult = SignupResult(value: myUser)
                            sut.signUp(recaptchaToken: nil)
                            
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                        
                        it("tracks a signupEmail event") {
                            let trackedEventNames = tracker.trackedEvents.compactMap { $0.name }
                            expect(trackedEventNames) == [EventName.signupEmail]
                        }
                        it("calls close after login in navigator when signup succeeds") {
                            expect(self.finishedSuccessfully).toEventually(beTrue())
                        }
                        it("saves letgo as previous user account provider") {
                            let provider = keyValueStorage[.previousUserAccountProvider]
                            expect(provider) == "letgo"
                        }
                        it("saves the user email as previous email") {
                            let username = keyValueStorage[.previousUserEmailOrName]
                            expect(username) == email
                        }
                        it("calls show and hide loading in delegate") {
                            expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                            expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        }
                    }
                }
            }
            
            describe("god mode") {
                describe("fill form with admin values") {
                    beforeEach {
                        sut.currentActionType = .login
                        sut.email.value = "admin"
                        sut.password.value = "wat"
                        sut.logIn()
                    }
                    
                    it("calls show god mode alert in delegate") {
                        expect(self.delegateReceivedShowGodModeAlert) == true
                    }
                }
                
                describe("enable god mode") {
                    context("wrong password") {
                        beforeEach {
                            sut.godLogIn("whatever")
                        }
                        
                        it("does not enable god mode") {
                            expect(keyValueStorage[.isGod]) == false
                        }
                    }
                    
                    context("correct password") {
                        beforeEach {
                            sut.godLogIn("mellongod")
                        }
                        
                        it("enables god mode") {
                            expect(keyValueStorage[.isGod]) == true
                        }
                    }
                }
            }
            
            describe("forgot password press") {
                beforeEach {
                    sut.openRememberPassword()
                }
                
                it("calls open remember password in navigator") {
                    expect(self.navigatorReceivedOpenRememberPassword) == true
                }
            }
            
            describe("help button press") {
                beforeEach {
                    sut.openHelp()
                }
                
                it("calls open help in navigator") {
                    expect(self.navigatorReceivedOpenHelp) == true
                }
            }
            
            describe("close button press") {
                beforeEach {
                    sut.cancel()
                }
                
                it("calls cancel in navigator") {
                    expect(self.finishedSuccessfully) == false
                }
            }
            
            describe("erase password") {
                beforeEach {
                    sut.password.value = "r4ndom_password"
                    sut.erasePassword()
                }
                
                it("sets password string to empty") {
                    expect(sut.password.value) == ""
                }
            }
            
            describe("accept suggested email") {
                
                var isSuggestedEmail = false
                
                context("email with available suggestion") {
                    let inputEmail = "raul@g"
                    
                    beforeEach {
                        sut.email.value = inputEmail
                        isSuggestedEmail = sut.acceptSuggestedEmail()
                    }
                    
                    it("applies the email change ") {
                        expect(isSuggestedEmail).to(beTrue())
                    }
                    it("changes the email string") {
                        expect(sut.email.value) != inputEmail
                    }
                }
                
                context("email without available suggestion") {
                    let inputEmail = "raul"
                    
                    beforeEach {
                        sut.email.value = inputEmail
                        isSuggestedEmail = sut.acceptSuggestedEmail()
                    }
                    
                    it("does not apply any email change ") {
                        expect(isSuggestedEmail).to(beFalse())
                    }
                    it("does not change the email string") {
                        expect(sut.email.value) == inputEmail
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
    func closeSignUpLogInAndOpenDeviceNotAllowedAlert(contactURL: URL, network: EventParameterAccountNetwork) {
        finishedSuccessfully = false
        finishedDeviceNotAllowed = true
    }
    func openRecaptcha(action: LoginActionType) {
        openRecaptchaCalled = true
    }

    func openRememberPasswordFromSignUpLogIn(email: String?) {
        navigatorReceivedOpenRememberPassword = true
    }
    func openHelpFromSignUpLogin() {
        navigatorReceivedOpenHelp = true
    }
    func open(url: URL) {}
}

extension SignUpLogInViewModelSpec: SignUpLogInViewModelDelegate {
    func vmShowHiddenPasswordAlert() {
        delegateReceivedShowGodModeAlert = true
    }
}
