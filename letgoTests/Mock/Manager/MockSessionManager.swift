//
//  MockSessionManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

class MockSessionManager: SessionManager {
    var signUpResult: SessionMyUserResult!
    var logInResult: SessionMyUserResult!
    var resetPasswordResult: SessionEmptyResult!

    
    // MARK: - SessionManager

    var sessionEvents: Observable<SessionEvent> = PublishSubject<SessionEvent>()

    var loggedIn: Bool = false

    func signUp(_ email: String, password: String, name: String, newsletter: Bool?,
                completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: signUpResult)
    }

    func signUp(_ email: String, password: String, name: String, newsletter: Bool?, recaptchaToken: String,
                completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: signUpResult)
    }

    func login(_ email: String, password: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: logInResult)
    }

    func loginFacebook(_ token: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: logInResult)
    }

    func loginGoogle(_ token: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: logInResult)
    }

    func recoverPassword(_ email: String, completion: SessionEmptyCompletion?) {
        performAfterDelayWithCompletion(completion, result: resetPasswordResult)
    }

    func logout() {
    }

    func connectChat() {
    }

    func disconnectChat() {
    }
}
