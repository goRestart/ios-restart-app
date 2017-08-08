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
    //var loading: Bool = false
    var finishedSuccessfully: Bool = false
    var finishedScammer: Bool = false
    var finishedDeviceNotAllowed: Bool = false
    
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
            
            var logInEnabled: Bool!
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
                    locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                    fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                    locale: locale, source: .install, action: .signup)
                sut.delegate = self
                sut.navigator = self

                //self.loading = false
                self.finishedSuccessfully = false
                self.finishedScammer = false
                self.finishedDeviceNotAllowed = false
                
                self.delegateReceivedShowGodModeAlert = false
                self.navigatorReceivedOpenRememberPassword = false
                self.navigatorReceivedOpenHelp = false
                
                disposeBag = DisposeBag()
                sut.logInEnabled.subscribeNext { enabled in
                    logInEnabled = enabled
                    }.addDisposableTo(disposeBag)
            }

            describe("initialization") {
                context("common") {
                    it("has an empty username") {
                        expect(sut.username.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
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
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
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
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
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
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
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

                context("phone locale is in Turkey") {
                    beforeEach {
                        let locale = Locale(identifier: "tr_TR")
                        sut = SignUpLogInViewModel(sessionManager: sessionManager, installationRepository:  installationRepository,
                            locationManager: locationManager, keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, featureFlags: featureFlags,
                            locale: locale , source: .install, action: .signup)
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
                            locale: locale , source: .install, action: .signup)
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

                        self.delegateReceivedHideLoading = false
                        _ = sut.logIn()
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
                            self.delegateReceivedHideLoading = false
                            _ = sut.logIn()
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
                            self.delegateReceivedHideLoading = false
                            _ = sut.logIn()
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
                            self.delegateReceivedHideLoading = false
                            _ = sut.logIn()
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
                            self.delegateReceivedHideLoading = false
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
                            self.delegateReceivedHideLoading = false
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
                }
            }
            
            describe("log in button press with invalid form") {
                var errors: LogInEmailFormErrors!
                
                context("empty") {
                    beforeEach {
                        sut.email.value = ""
                        sut.password.value = ""
                        errors = sut.logIn()
                    }
                    
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                    it("does not return any error") {
                        expect(errors) == []
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }
                
                context("with email non-valid & short password") {
                    beforeEach {
                        sut.currentActionType = .login
                        sut.email.value = "a"
                        sut.password.value = "a"
                        errors = sut.logIn()
                    }
                    
                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns that the email is invalid and the password is short") {
                        expect(errors) == [.invalidEmail, .shortPassword]
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                }

                context("with valid email & long password") {
                    beforeEach {
                        sut.currentActionType = .login
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "abcdefghijklmnopqrstuvwxyz"
                        errors = sut.logIn()
                    }
                    
                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns that the password is long") {
                        expect(errors) == [.longPassword]
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                }

                context("with valid email & password") {
                    beforeEach {
                        sut.currentActionType = .login
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "letitgo"
                        errors = sut.logIn()
                    }
                    
                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns no errors") {
                        expect(errors) == []
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }
            }
            
            describe("log in button press with valid form") {
                var errors: LogInEmailFormErrors!
                
                beforeEach {
                    sut.currentActionType = .login
                    sut.email.value = "albert@letgo.com"
                    sut.password.value = "letitgo"
                    errors = sut.logIn()
                }
                
                it("has log in enabled") {
                    expect(logInEnabled) == true
                }
                it("returns no errors") {
                    expect(errors) == []
                }
                it("does not track any event") {
                    let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                    expect(trackedEventNames) == []
                }
                it("calls show and hide loading in delegate") {
                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
                    expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                }
            }
            
            describe("log in valid form") {
                beforeEach {
                    sut.currentActionType = .login
                    sut.email.value = "albert@letgo.com"
                    sut.password.value = "letitgo"
                }
                
                context("log in fails once with unauthorized error") {
                    beforeEach {
                        sessionManager.logInResult = LoginResult(error: .unauthorized)
                        self.delegateReceivedHideLoading = false
                        _ = sut.logIn()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("does not call show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert) == false
                    }
                }
                
                context("log in fails twice with unauthorized error") {
                    beforeEach {
                        sut.currentActionType = .login
                        sessionManager.logInResult = LoginResult(error: .unauthorized)
                        self.delegateReceivedHideLoading = false
                        _ = sut.logIn()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        self.delegateReceivedHideLoading = false
                        
                        _ = sut.logIn()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    
                    it("tracks two loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("calls show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert).toEventually(beTrue())
                    }
                }
                
                context("log in fails twice with another error") {
                    beforeEach {
                        sut.currentActionType = .login
                        sessionManager.logInResult = LoginResult(error: .network)
                        self.delegateReceivedHideLoading = false
                        self.delegateReceivedShowAlert = false
                        _ = sut.logIn()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                        self.delegateReceivedHideLoading = false
                        self.delegateReceivedShowAlert = false
                        _ = sut.logIn()
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    
                    it("tracks two loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("does not call show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert) == false
                    }
                }
                
                context("log in fails with scammer error") {
                    beforeEach {
                        sut.currentActionType = .login
                        sessionManager.logInResult = LoginResult(error: .scammer)
                        self.delegateReceivedHideLoading = false
                        _ = sut.logIn()
                        
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("calls open scammer alert in the navigator") {
                        expect(self.finishedScammer).toEventually(beTrue())
                    }
                }
                
                context("log in fails with device not allowed error") {
                    beforeEach {
                        sut.currentActionType = .login
                        self.delegateReceivedHideLoading = false
                        sessionManager.logInResult = LoginResult(error: .deviceNotAllowed)
                        _ = sut.logIn()
                        
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("calls open device not allowed alert in the navigator") {
                        expect(self.finishedDeviceNotAllowed).toEventually(beTrue())
                    }
                }
                
                context("log in succeeds") {
                    let email = "albert.hernandez@gmail.com"
                    
                    beforeEach {
                        sut.currentActionType = .login
                        var myUser = MockMyUser.makeMock()
                        myUser.email = email
                        sessionManager.logInResult = LoginResult(value: myUser)
                        self.delegateReceivedHideLoading = false
                        _ = sut.logIn()
                        
                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }
                    
                    it("tracks a loginEmail event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
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
                }
            }
            
            
            describe("sign up button press with invalid form") {
                var errors: SignUpFormErrors!
                
                beforeEach {
                    sut.currentActionType = .signup
                }
                
                context("empty") {
                    beforeEach {
                        sut.email.value = ""
                        sut.password.value = ""
                        sut.username.value = ""
                        errors = sut.signUp(nil)
                    }
                    
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                    it("does not return any error") {
                        expect(errors) == []
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }
                
                context("with email non-valid & short password") {
                    beforeEach {
                        sut.email.value = "a"
                        sut.password.value = "a"
                        sut.username.value = "a"
                        errors = sut.signUp(nil)
                    }
                    
                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns that the email is invalid, the password is short and the user is invalid") {
                        expect(errors) == [.invalidEmail, .shortPassword, .invalidUsername]
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("tracks a signupError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                }
                
                context("with valid email, valid username but long password") {
                    beforeEach {
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "abcdefghijklmnopqrstuvwxyz"
                        sut.username.value = "albert"
                        errors = sut.signUp(nil)
                    }
                    
                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns that the password is long") {
                        expect(errors) == [.longPassword]
                    }
                    it("does not call close because after login in navigator") {
                        expect(self.finishedSuccessfully) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.signupError]
                    }
                }
                
                context("with valid email, password and username") {
                    beforeEach {
                        sut.email.value = "albert@letgo.com"
                        sut.password.value = "letitgo"
                        sut.username.value = "albert"
                        errors = sut.signUp(nil)
                    }
                    
                    it("has log in enabled") {
                        expect(logInEnabled) == true
                    }
                    it("returns no errors") {
                        expect(errors) == []
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }
            }
            
//            describe("log in button press with valid form") {
//                var errors: LogInEmailFormErrors!
//                
//                beforeEach {
//                    sut.currentActionType = .login
//                    sut.email.value = "albert@letgo.com"
//                    sut.password.value = "letitgo"
//                    errors = sut.logIn()
//                }
//                
//                it("has log in enabled") {
//                    expect(logInEnabled) == true
//                }
//                it("returns no errors") {
//                    expect(errors) == []
//                }
//                it("does not track any event") {
//                    let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                    expect(trackedEventNames) == []
//                }
//                it("calls show and hide loading in delegate") {
//                    expect(self.delegateReceivedShowLoading).toEventually(beTrue())
//                    expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                }
//            }
//            
//            context("valid form") {
//                beforeEach {
//                    sut.currentActionType = .login
//                    sut.email.value = "albert@letgo.com"
//                    sut.password.value = "letitgo"
//                }
//                
//                describe("log in fails once with unauthorized error") {
//                    beforeEach {
//                        sessionManager.logInResult = LoginResult(error: .unauthorized)
//                        self.delegateReceivedHideLoading = false
//                        _ = sut.logIn()
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                    }
//                    
//                    it("tracks a loginEmailError event") {
//                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                        expect(trackedEventNames) == [EventName.loginEmailError]
//                    }
//                    it("does not call close after login in navigator") {
//                        expect(self.finishedSuccessfully) == false
//                    }
//                    it("does not call show alert in the delegate to suggest reset pwd") {
//                        expect(self.delegateReceivedShowAlert) == false
//                    }
//                }
//                
//                describe("log in fails twice with unauthorized error") {
//                    beforeEach {
//                        sut.currentActionType = .login
//                        sessionManager.logInResult = LoginResult(error: .unauthorized)
//                        self.delegateReceivedHideLoading = false
//                        _ = sut.logIn()
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                        self.delegateReceivedHideLoading = false
//                        
//                        _ = sut.logIn()
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                    }
//                    
//                    it("tracks two loginEmailError event") {
//                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                        expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
//                    }
//                    it("does not call close after login in navigator") {
//                        expect(self.finishedSuccessfully) == false
//                    }
//                    it("calls show alert in the delegate to suggest reset pwd") {
//                        expect(self.delegateReceivedShowAlert).toEventually(beTrue())
//                    }
//                }
//                
//                describe("log in fails twice with another error") {
//                    beforeEach {
//                        sut.currentActionType = .login
//                        sessionManager.logInResult = LoginResult(error: .network)
//                        self.delegateReceivedHideLoading = false
//                        self.delegateReceivedShowAlert = false
//                        _ = sut.logIn()
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                        self.delegateReceivedHideLoading = false
//                        self.delegateReceivedShowAlert = false
//                        _ = sut.logIn()
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                    }
//                    
//                    it("tracks two loginEmailError event") {
//                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                        expect(trackedEventNames) == [EventName.loginEmailError, EventName.loginEmailError]
//                    }
//                    it("does not call close after login in navigator") {
//                        expect(self.finishedSuccessfully) == false
//                    }
//                    it("does not call show alert in the delegate to suggest reset pwd") {
//                        expect(self.delegateReceivedShowAlert) == false
//                    }
//                }
//                
//                describe("log in fails with scammer error") {
//                    beforeEach {
//                        sut.currentActionType = .login
//                        sessionManager.logInResult = LoginResult(error: .scammer)
//                        self.delegateReceivedHideLoading = false
//                        _ = sut.logIn()
//                        
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                    }
//                    
//                    it("tracks a loginEmailError event") {
//                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                        expect(trackedEventNames) == [EventName.loginEmailError]
//                    }
//                    it("does not call close after login in navigator") {
//                        expect(self.finishedSuccessfully) == false
//                    }
//                    it("calls open scammer alert in the navigator") {
//                        expect(self.finishedScammer).toEventually(beTrue())
//                    }
//                }
//                
//                describe("log in fails with device not allowed error") {
//                    beforeEach {
//                        sut.currentActionType = .login
//                        self.delegateReceivedHideLoading = false
//                        sessionManager.logInResult = LoginResult(error: .deviceNotAllowed)
//                        _ = sut.logIn()
//                        
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                    }
//                    
//                    it("tracks a loginEmailError event") {
//                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                        expect(trackedEventNames) == [EventName.loginEmailError]
//                    }
//                    it("does not call close after login in navigator") {
//                        expect(self.finishedSuccessfully) == false
//                    }
//                    it("calls open device not allowed alert in the navigator") {
//                        expect(self.finishedDeviceNotAllowed).toEventually(beTrue())
//                    }
//                }
//                
//                describe("log in succeeds") {
//                    let email = "albert.hernandez@gmail.com"
//                    
//                    beforeEach {
//                        sut.currentActionType = .login
//                        var myUser = MockMyUser.makeMock()
//                        myUser.email = email
//                        sessionManager.logInResult = LoginResult(value: myUser)
//                        self.delegateReceivedHideLoading = false
//                        _ = sut.logIn()
//                        
//                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
//                    }
//                    
//                    it("tracks a loginEmail event") {
//                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
//                        expect(trackedEventNames) == [EventName.loginEmail]
//                    }
//                    it("calls close after login in navigator when signup succeeds") {
//                        expect(self.finishedSuccessfully).toEventually(beTrue())
//                    }
//                    it("saves letgo as previous user account provider") {
//                        let provider = keyValueStorage[.previousUserAccountProvider]
//                        expect(provider) == "letgo"
//                    }
//                    it("saves the user email as previous email") {
//                        let username = keyValueStorage[.previousUserEmailOrName]
//                        expect(username) == email
//                    }
//                }
//            }
            
            context("god mode") {
                describe("fill form with admin values") {
                    beforeEach {
                        sut.currentActionType = .login
                        sut.email.value = "admin"
                        sut.password.value = "wat"
                        _ = sut.logIn()
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
                
                describe("remember password press") {
                    beforeEach {
                        sut.openRememberPassword()
                    }
                    
                    it("calls open remember password in navigator") {
                        expect(self.navigatorReceivedOpenRememberPassword) == true
                    }
                }
            }
            
//            describe("footer button press") {
//                beforeEach {
//                    sut.footerButtonPressed()
//                }
//                
//                it("calls open sign up navigator") {
//                    expect(self.navigatorReceivedOpenSignUp) == true
//                }
//            }
            
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
    func openRecaptcha(transparentMode: Bool) {}

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
