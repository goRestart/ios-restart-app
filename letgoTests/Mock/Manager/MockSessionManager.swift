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
    var myUserResult: SessionMyUserResult!
    var resetPasswordResult: SessionEmptyResult!

    
    // MARK: - SessionManager

    var sessionEvents: Observable<SessionEvent> = PublishSubject<SessionEvent>()

    var loggedIn: Bool = false

    func signUp(_ email: String, password: String, name: String, newsletter: Bool?,
                completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func signUp(_ email: String, password: String, name: String, newsletter: Bool?, recaptchaToken: String,
                completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func login(_ email: String, password: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func loginFacebook(_ token: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
    }

    func loginGoogle(_ token: String, completion: SessionMyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult)
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
