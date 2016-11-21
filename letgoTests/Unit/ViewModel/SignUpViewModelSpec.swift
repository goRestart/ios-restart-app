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

            beforeEach {
                sessionManager = MockSessionManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                googleLoginHelper = MockExternalAuthHelper(result: .Success(myUser: MockMyUser()))
                sut = SignUpViewModel(sessionManager: sessionManager, keyValueStorage: keyValueStorage,
                                      tracker: tracker, appearance: .Dark, source: .Install,
                                      googleLoginHelper: googleLoginHelper)
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
                            googleLoginHelper: googleLoginHelper)
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
                            googleLoginHelper: googleLoginHelper)
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
                            googleLoginHelper: googleLoginHelper)
                    }

                    it("does not have a previous facebook username") {
                        expect(sut.previousFacebookUsername.value).to(beNil())
                    }
                    it("has a previous google username") {
                        expect(sut.previousGoogleUsername.value) == "Albert Google"
                    }
                }
            }

            describe("login with google successful") {
                beforeEach {
                    let myUser = MockMyUser()
                    myUser.name = "Albert"

//                    sessionManager.myUserResult = Result<MyUser, SessionManagerError>(value: myUser)
                    googleLoginHelper.loginResult = .Success(myUser: myUser)

                    sut.logInWithGoogle()
                }

                it("saves google as previous user account provider") {
                    let provider = keyValueStorage[.previousUserAccountProvider]
                    expect(provider) == "google"
                }
                it("saves the user name as previous user name") {
                    let username = keyValueStorage[.previousUserEmailOrName]
                    expect(username) == "Albert"
                }
            }
        }
    }
}
