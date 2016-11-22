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
    
    override func spec() {

        describe("SignUpViewModelSpec") {
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
                sut.delegate = self

                self.loading = false
                self.finishedSuccessfully = false
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
                    it("tracks login-screen & login-signup-error-google events") {
                        expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-google"]
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
                    it("tracks login-screen & login-fb events") {
                        expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-fb"]
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
                    it("tracks login-screen & login-signup-error-facebook events") {
                        expect(tracker.trackedEvents.map({ $0.actualName })) == ["login-screen", "login-signup-error-facebook"]
                    }
                }
            }
        }
    }
}

extension SignUpViewModelSpec: SignUpViewModelDelegate {
    func viewModelDidStartLoggingIn(viewModel: SignUpViewModel) {
        loading = true
    }
    func viewModeldidFinishLoginIn(viewModel: SignUpViewModel) {
        loading = false
        finishedSuccessfully = true
    }
    func viewModeldidCancelLoginIn(viewModel: SignUpViewModel) {
        loading = false
        finishedSuccessfully = false
    }
    func viewModel(viewModel: SignUpViewModel, didFailLoginIn message: String) {
        loading = false
        finishedSuccessfully = false
    }
}
