//
//  LogInEmailViewModelSpec.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit
import Quick
import Nimble
import Result
import RxSwift

class LogInEmailViewModelSpec: QuickSpec {
    var delegateReceivedShowLoading = false
    var delegateReceivedHideLoading = false
    var delegateReceivedShowAlert = false
    var delegateReceivedShowGodModeAlert = false

    var navigatorReceivedOpenHelp = false
    var navigatorReceivedOpenRememberPassword = false
    var navigatorReceivedOpenSignUp = false
    var navigatorReceiverOpenScammerAlert = false
    var navigatorReceivedCloseAfterLogIn = false

    override func spec() {

        describe("LogInEmailViewModel") {
            var sessionManager: MockSessionManager!
            var keyValueStorage: MockKeyValueStorage!
            var tracker: MockTracker!

            var email: String!
            var suggestedEmail: String!
            var logInEnabled: Bool!

            var disposeBag: DisposeBag!
            var sut: LogInEmailViewModel!

            beforeEach {
                self.delegateReceivedShowLoading = false
                self.delegateReceivedHideLoading = false
                self.delegateReceivedShowAlert = false
                self.delegateReceivedShowGodModeAlert = false

                self.navigatorReceivedOpenHelp = false
                self.navigatorReceivedOpenRememberPassword = false
                self.navigatorReceivedOpenSignUp = false
                self.navigatorReceiverOpenScammerAlert = false
                self.navigatorReceivedCloseAfterLogIn = false

                sessionManager = MockSessionManager()
                keyValueStorage = MockKeyValueStorage()
                tracker = MockTracker()
                disposeBag = DisposeBag()

                let myUser = MockMyUser()
                myUser.email = "albert@letgo.com"
                sessionManager.logInResult = SessionMyUserResult(value: myUser)

                sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                          source: .sell, sessionManager: sessionManager,
                                          keyValueStorage: keyValueStorage, tracker: tracker)
                sut.email.asObservable().subscribeNext { newEmail in
                    email = newEmail
                }.addDisposableTo(disposeBag)
                sut.suggestedEmail.subscribeNext { email in
                    suggestedEmail = email
                }.addDisposableTo(disposeBag)
                sut.logInEnabled.subscribeNext { enabled in
                    logInEnabled = enabled
                }.addDisposableTo(disposeBag)
                sut.delegate = self
                sut.navigator = self
            }

            describe("initialization") {
                context("did not log in previously") {
                    beforeEach {
                        sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                                  source: .sell, sessionManager: sessionManager,
                                                  keyValueStorage: keyValueStorage, tracker: tracker)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }

                context("previously logged in by email") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "letgo"
                        keyValueStorage[.previousUserEmailOrName] = "albert@letgo.com"

                        sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                                  source: .sell, sessionManager: sessionManager,
                                                  keyValueStorage: keyValueStorage, tracker: tracker)
                    }

                    it("has an email") {
                        expect(sut.email.value) == "albert@letgo.com"
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }

                context("previously logged in by facebook") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "facebook"
                        keyValueStorage[.previousUserEmailOrName] = "Albert FB"

                        sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                                  source: .sell, sessionManager: sessionManager,
                                                  keyValueStorage: keyValueStorage, tracker: tracker)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }

                context("previously logged in by google") {
                    beforeEach {
                        keyValueStorage[.previousUserAccountProvider] = "google"
                        keyValueStorage[.previousUserEmailOrName] = "Albert Google"

                        sut = LogInEmailViewModel(email: nil, isRememberedEmail: false,
                                                  source: .sell, sessionManager: sessionManager,
                                                  keyValueStorage: keyValueStorage, tracker: tracker)
                    }

                    it("has an empty email") {
                        expect(sut.email.value) == ""
                    }
                    it("has an empty password") {
                        expect(sut.password.value) == ""
                    }
                    it("has log in disabled") {
                        expect(logInEnabled) == false
                    }
                }
            }

            describe("autosuggest email") {
                describe("empty") {
                    beforeEach {
                        sut.email.value = ""
                        sut.acceptSuggestedEmail()
                    }

                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == ""
                    }
                }

                describe("user letters") {
                    beforeEach {
                        sut.email.value = "albert"
                        sut.acceptSuggestedEmail()
                    }

                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert"
                    }
                }

                describe("user letters and @ sign") {
                    beforeEach {
                        sut.email.value = "albert@"
                        sut.acceptSuggestedEmail()
                    }

                    it("does not suggest anything") {
                        expect(suggestedEmail).to(beNil())
                        sut.acceptSuggestedEmail()
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert@"
                    }
                }

                describe("user letters, @ sign & first domain letters") {
                    beforeEach {
                        sut.email.value = "albert@g"
                        sut.acceptSuggestedEmail()
                    }

                    it("suggests first domain ocurrence") {
                        expect(suggestedEmail) == "albert@gmail.com"
                    }
                    it("does not update the email when accepting") {
                        expect(email) == "albert@gmail.com"
                    }
                }
            }

            describe("log in with invalid form") {
                var errors: LogInEmailFormErrors!

                describe("empty") {
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
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("does not track any event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == []
                    }
                }

                describe("with email non-valid & short password") {
                    beforeEach {
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
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                }

                describe("with valid email & long password") {
                    beforeEach {
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
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                }

                describe("with valid email & password") {
                    beforeEach {
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

            describe("log in with valid form") {
                var errors: LogInEmailFormErrors!

                beforeEach {
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

            context("valid form") {
                beforeEach {
                    sut.email.value = "albert@letgo.com"
                    sut.password.value = "letitgo"
                }

                describe("log in fails with unauthorized error once") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .unauthorized)
                        _ = sut.logIn()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                }

                describe("log in fails with unauthorized error twice") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .unauthorized)
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
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("calls show alert in the delegate to suggest reset pwd") {
                        expect(self.delegateReceivedShowAlert) == true
                    }
                }

                describe("log in fails with scammer error") {
                    beforeEach {
                        sessionManager.logInResult = SessionMyUserResult(error: .scammer)
                        _ = sut.logIn()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a loginEmailError event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmailError]
                    }
                    it("does not call close after login in navigator") {
                        expect(self.navigatorReceivedCloseAfterLogIn) == false
                    }
                    it("calls open scammer alert in the navigator") {
                        expect(self.navigatorReceiverOpenScammerAlert) == true
                    }
                }

                describe("log in succeeds") {
                    let email = "albert.hernandez@gmail.com"

                    beforeEach {
                        let myUser = MockMyUser()
                        myUser.email = email
                        sessionManager.logInResult = SessionMyUserResult(value: myUser)
                        _ = sut.logIn()

                        expect(self.delegateReceivedHideLoading).toEventually(beTrue())
                    }

                    it("tracks a loginEmail event") {
                        let trackedEventNames = tracker.trackedEvents.flatMap { $0.name }
                        expect(trackedEventNames) == [EventName.loginEmail]
                    }
                    it("calls close after login in navigator when signup succeeds") {
                        expect(self.navigatorReceivedCloseAfterLogIn).toEventually(beTrue())
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


            context("god mode") {
                describe("fill form with admin values") {
                    beforeEach {
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
                            sut.enableGodMode(godPassword: "whatever")
                        }

                        it("does not enable god mode") {
                            expect(keyValueStorage[.isGod]) == false
                        }
                    }

                    context("correct password") {
                        beforeEach {
                            sut.enableGodMode(godPassword: "mellongod")
                        }

                        it("enables god mode") {
                            expect(keyValueStorage[.isGod]) == true
                        }
                    }
                }

                describe("open remember password") {
                    beforeEach {
                        sut.openRememberPassword()
                    }

                    it("calls open remember password in navigator") {
                        expect(self.navigatorReceivedOpenRememberPassword) == true
                    }
                }
            }

            describe("open sign up") {
                beforeEach {
                    sut.openSignUp()
                }

                it("calls open sign up navigator") {
                    expect(self.navigatorReceivedOpenSignUp) == true
                }
            }

            describe("open help") {
                beforeEach {
                    sut.helpAction.action()
                }
                
                it("calls open help in navigator") {
                    expect(self.navigatorReceivedOpenHelp) == true
                }
            }
        }
    }
}

extension LogInEmailViewModelSpec: LogInEmailViewModelDelegate {
    func vmGodModePasswordAlert() {
        delegateReceivedShowGodModeAlert = true
    }

    func vmShowAutoFadingMessage(_ message: String, completion: (() -> ())?) {
        completion?()
    }

    func vmShowLoading(_ loadingMessage: String?) {
        self.delegateReceivedShowLoading = true
    }

    func vmHideLoading(_ finishedMessage: String?, afterMessageCompletion: (() -> ())?) {
        self.delegateReceivedHideLoading = true
        afterMessageCompletion?()
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, actions: [UIAction]?) {
        self.delegateReceivedShowAlert = true
    }

    func vmShowAlertWithTitle(_ title: String?, text: String, alertType: AlertType, buttonsLayout: AlertButtonsLayout, actions: [UIAction]?) {
        self.delegateReceivedShowAlert = true
    }

    func vmShowAlert(_ title: String?, message: String?, actions: [UIAction]) {
        self.delegateReceivedShowAlert = true
    }

    func vmShowAlert(_ title: String?, message: String?, cancelLabel: String, actions: [UIAction]) {
        self.delegateReceivedShowAlert = true
    }

    func vmShowActionSheet(_ cancelAction: UIAction, actions: [UIAction]) {}
    func vmShowActionSheet(_ cancelLabel: String, actions: [UIAction]) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}
    func ifLoggedInThen(_ source: EventParameterLoginSourceValue, loginStyle: LoginStyle, loggedInAction: () -> Void,
                        elsePresentSignUpWithSuccessAction afterLogInAction: @escaping () -> Void) {}

    func vmPop() {}
    func vmDismiss(_ completion: (() -> Void)?) {}

    func vmOpenInternalURL(_ url: URL) {}
}

extension LogInEmailViewModelSpec: LogInEmailViewModelNavigator {
    func openHelpFromLogInEmail() {
        navigatorReceivedOpenHelp = true
    }

    func openRememberPasswordFromLogInEmail(email: String) {
        navigatorReceivedOpenRememberPassword = true
    }

    func openSignUpEmailFromLogInEmail(email: String, password: String) {
        navigatorReceivedOpenSignUp = true
    }

    func openScammerAlertFromLogInEmail() {
        navigatorReceiverOpenScammerAlert = true
    }

    func closeAfterLogInSuccessful() {
        navigatorReceivedCloseAfterLogIn = true
    }
}
