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
    override func spec() {

        fdescribe("SignUpLogInViewModelSpec") {
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

                sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                    keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                    fbLoginHelper: fbLoginHelper, tracker: tracker, source: .Install, action: .Signup)
            }

            describe("initialization") {
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

                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, source: .Install, action: .Signup)
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

                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, source: .Install, action: .Signup)
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

                        sut = SignUpLogInViewModel(sessionManager: sessionManager, locationManager: locationManager,
                            keyValueStorage: keyValueStorage, googleLoginHelper: googleLoginHelper,
                            fbLoginHelper: fbLoginHelper, tracker: tracker, source: .Install, action: .Signup)
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
                    }

                    it("saves letgo as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "letgo"
                    }
                    it("saves the user email as previous email") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == myUser.email
                    }
                }

                context("error") {
                    beforeEach {
                        let email = "albert@letgo.com"
                        sessionManager.myUserResult = SessionMyUserResult(error: .Network)

                        sut.email = email
                        sut.password = "123456"
                        sut.logIn()
                    }

                    it("does not save a user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider).to(beNil())
                    }
                    it("does not save a previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username).to(beNil())
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
                    }

                    it("saves google as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "google"
                    }
                    it("saves the user name as previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == myUser.name
                    }
                }

                context("error") {
                    beforeEach {
                        googleLoginHelper.loginResult = .Cancelled
                        sut.logInWithGoogle()
                    }

                    it("does not save a user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider).to(beNil())
                    }
                    it("does not save a previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username).to(beNil())
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
                    }

                    it("saves google as previous user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider) == "facebook"
                    }
                    it("saves the user name as previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username) == myUser.name
                    }
                }

                context("error") {
                    beforeEach {
                        fbLoginHelper.loginResult = .Cancelled
                        sut.logInWithFacebook()
                    }

                    it("does not save a user account provider") {
                        let provider = keyValueStorage[.previousUserAccountProvider]
                        expect(provider).to(beNil())
                    }
                    it("does not save a previous user name") {
                        let username = keyValueStorage[.previousUserEmailOrName]
                        expect(username).to(beNil())
                    }
                }
            }
        }
    }
}
