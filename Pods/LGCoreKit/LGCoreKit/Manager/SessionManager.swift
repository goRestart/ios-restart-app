//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 16/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias LoginResult = Result<MyUser, LoginError>
public typealias LoginCompletion = (LoginResult) -> Void

public typealias SignupResult = Result<MyUser, SignupError>
public typealias SignupCompletion = (SignupResult) -> Void

public typealias RecoverPasswordResult = Result<Void, RecoverPasswordError>
public typealias RecoverPasswordCompletion = (RecoverPasswordResult) -> Void


public enum SessionEvent {
    case login
    case logout(kickedOut: Bool)
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
    func signUp(_ email: String, password: String, name: String, newsletter: Bool?,
        completion: SignupCompletion?)

    /**
     Signs up with the given credentials and public user name, if recaptcha verification is ok.
     - parameter email: The email.
     - parameter password: The password.
     - parameter name: The name.
     - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
     - parameter recaptchaToken: Recaptcha token.
     - parameter completion: The completion closure.
     */
    func signUp(_ email: String, password: String, name: String, newsletter: Bool?, recaptchaToken: String,
                       completion: SignupCompletion?)

    /**
    Logs the user in via email.
    - parameter email: The email.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    func login(_ email: String, password: String, completion: LoginCompletion?)

    /**
    Logs the user in via Facebook.
    - parameter token: The Facebook token.
    - parameter completion: The completion closure.
    */
    func loginFacebook(_ token: String, completion: LoginCompletion?)
    
    /**
     Logs the user in via Google
     
     - parameter token:      The Google token
     - parameter completion: The completion closure
     */
    func loginGoogle(_ token: String, completion: LoginCompletion?)

    /**
    Requests a password recovery.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    func recoverPassword(_ email: String, completion: RecoverPasswordCompletion?)

    /**
    Logs the user out.
    */
    func logout()

    /**
     Starts the chat, will open websocket and authenticate on demand
     */
    func startChat()
}


// MARK: - Internal

/**
 Defines the user session providers in letgo API.
 */
enum UserSessionProvider {
    case email(email: String, password: String)
    case facebook(facebookToken: String)
    case google(googleToken: String)

    var accountProvider: AccountProvider {
        switch self {
        case .email:
            return .email
        case .facebook:
            return .facebook
        case .google:
            return .google
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
    func authenticateInstallation(_ completion: ((Result<Installation, ApiError>) -> ())?)

    /**
     Renews the user token.

     Note: Should be only called by `ApiClient` and `WebSocketClient`

     - parameter completion:    The completion closure.
     */
    func renewUserToken(_ completion: ((Result<Authentication, ApiError>) -> ())?)

    /**
     Sets up after logging-out.
     */
    func tearDownSession(kicked: Bool)

    func authenticateWebSocket()
}

