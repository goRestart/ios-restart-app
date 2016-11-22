//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 16/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias SessionMyUserResult = Result<MyUser, SessionManagerError>
public typealias SessionMyUserCompletion = SessionMyUserResult -> Void

public typealias SessionEmptyResult = Result<Void, SessionManagerError>
public typealias SessionEmptyCompletion = SessionEmptyResult -> Void


public enum SessionEvent {
    case Login
    case Logout(kickedOut: Bool)
}

public protocol SessionManager: class {

    var sessionEvents: Observable<SessionEvent> { get }

    var loggedIn: Bool { get }

    /**
    Signs up with the given credentials and public user name.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
    - parameter completion: The completion closure.
    */
    func signUp(email: String, password: String, name: String, newsletter: Bool?,
        completion: SessionMyUserCompletion?)

    /**
     Signs up with the given credentials and public user name, if recaptcha verification is ok.
     - parameter email: The email.
     - parameter password: The password.
     - parameter name: The name.
     - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
     - parameter recaptchaToken: Recaptcha token.
     - parameter completion: The completion closure.
     */
    func signUp(email: String, password: String, name: String, newsletter: Bool?, recaptchaToken: String,
                       completion: SessionMyUserCompletion?)

    /**
    Logs the user in via email.
    - parameter email: The email.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    func login(email: String, password: String, completion: SessionMyUserCompletion?)

    /**
    Logs the user in via Facebook.
    - parameter token: The Facebook token.
    - parameter completion: The completion closure.
    */
    func loginFacebook(token: String, completion: SessionMyUserCompletion?)
    
    /**
     Logs the user in via Google
     
     - parameter token:      The Google token
     - parameter completion: The completion closure
     */
    func loginGoogle(token: String, completion: SessionMyUserCompletion?)

    /**
    Requests a password recovery.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    func recoverPassword(email: String, completion: SessionEmptyCompletion?)

    /**
    Logs the user out.
    */
    func logout()


    /**
    Connects the chat (will be done automatically too after login, startup)
    */
    func connectChat(completion: SessionEmptyCompletion?)

    /*
    Disconnects the chat
    */
    func disconnectChat()
}


// MARK: - Internal

/**
 Defines the user session providers in letgo API.
 */
enum UserSessionProvider {
    case Email(email: String, password: String)
    case Facebook(facebookToken: String)
    case Google(googleToken: String)

    var accountProvider: AccountProvider {
        switch self {
        case .Email:
            return .Email
        case .Facebook:
            return .Facebook
        case .Google:
            return .Google
        }
    }
}

protocol InternalSessionManager: SessionManager {


    /**
     Initializes `SessionManager`. Will cleanup tokens in case of clean installation
     */
    func initialize()

    // MARK: - Internal methods

    /**
     Authenticates (or creates if needed) the given installation.
     - parameter completion:    The completion closure.
     */
    func authenticateInstallation(completion: (Result<Installation, ApiError> -> ())?)

    /**
     Renews the user token.

     Note: Should be only called by `ApiClient` and `WebSocketClient`

     - parameter completion:    The completion closure.
     */
    func renewUserToken(completion: (Result<Authentication, ApiError> -> ())?)

    /**
     Sets up after logging-out.
     */
    func tearDownSession(kicked kicked: Bool)

    func authenticateWebSocket(completion: SessionEmptyCompletion?)
}

