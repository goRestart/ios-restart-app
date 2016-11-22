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
    override func spec() {

        fdescribe("SignUpViewModelSpec") {
            var sut: SignUpViewModel!
            var sessionManager: MockSessionManager!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!
            var googleLoginHelper: MockExternalAuthHelper!
            var fbLoginHelper: MockExternalAuthHelper!

            beforeEach {
                sessionManager = MockSessionManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                let myUser = MockMyUser()
                googleLoginHelper = MockExternalAuthHelper(result: .Success(myUser: myUser))
                fbLoginHelper = MockExternalAuthHelper(result: .Success(myUser: myUser))
                sut = SignUpViewModel(sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                    tracker: tracker, appearance: .Dark, source: .Install,
                    googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
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

                        sut = SignUpViewModel(sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                            tracker: tracker, appearance: .Dark, source: .Install,
                            googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
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

                        sut = SignUpViewModel(sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                            tracker: tracker, appearance: .Dark, source: .Install,
                            googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
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

                        sut = SignUpViewModel(sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                            tracker: tracker, appearance: .Dark, source: .Install,
                            googleLoginHelper: googleLoginHelper, fbLoginHelper: fbLoginHelper)
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
