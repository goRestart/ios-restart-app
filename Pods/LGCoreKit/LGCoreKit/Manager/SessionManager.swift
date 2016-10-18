//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 16/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Result
import RxSwift


// MARK: - SessionManagerError

public enum SessionManagerError: ErrorType {

    case Network
    case BadRequest(cause: BadRequestCause)
    case NotFound
    case Forbidden
    case Unauthorized
    case Conflict(cause: ConflictCause)
    case Scammer
    case NonExistingEmail
    case TooManyRequests
    case UserNotVerified
    case Internal(message: String)

    init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .BadRequest(let cause):
            self = .BadRequest(cause: cause)
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .Forbidden:
            self = .Forbidden
        case .Conflict(let cause):
            self = .Conflict(cause: cause)
        case .UnprocessableEntity:
            self = .NonExistingEmail
        case .Scammer:
            self = .Scammer
        case .TooManyRequests:
            self = .TooManyRequests
        case .UserNotVerified:
            self = .UserNotVerified
        case .InternalServerError:
            self = .Internal(message: "Internal Server Error")
        case let .Internal(description):
            self = .Internal(message: description)
        case let .Other(httpCode):
            self = .Internal(message: "\(httpCode) HTTP code is not handled")
        case .NotModified:
            self = .Internal(message: "Internal API Error")
        }
    }

    init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .Network:
            self = .Network
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .Forbidden:
            self = .Forbidden
        case .TooManyRequests:
            self = .TooManyRequests
        case .UserNotVerified:
            self = .UserNotVerified
        case let .Internal(message):
            self = .Internal(message: message)
        case .ServerError:
            self = .Internal(message: "Internal Server Error")
        }
    }

    init(webSocketError: WebSocketError) {
        switch webSocketError {
        case .NotAuthenticated:
            self = .Unauthorized
        case .Internal:
            self = .Internal(message: "")
        case .UserNotVerified:
            self = .UserNotVerified
        }
    }
}


// MARK: - HOF

/**
Handles the given API result and executes a completion with a `SessionManagerError`.
- parameter result: The result to handle.
- parameter success: A completion block that is executed only on successful result.
- parameter completion: A completion block that is executed on both successful & failure result.
*/
func handleApiResult<T>(result: Result<T, ApiError>, completion: ((Result<T, SessionManagerError>) -> ())?) {
    handleApiResult(result, success: nil, failed: nil, completion: completion)
}

func handleApiResult<T>(result: Result<T, ApiError>,
    success: ((T) -> ())?,
    completion: ((Result<T, SessionManagerError>) -> ())?) {
        handleApiResult(result, success: success, failed: nil, completion: completion)
}

func handleApiResult<T>(result: Result<T, ApiError>,
    success: ((T) -> ())?,
    failed: ((ApiError) -> ())?,
    completion: ((Result<T, SessionManagerError>) -> ())?) {
        if let value = result.value {
            success?(value)
            completion?(Result<T, SessionManagerError>(value: value))
        } else if let apiError = result.error {
            failed?(apiError)
            let error = SessionManagerError(apiError: apiError)
            completion?(Result<T, SessionManagerError>(error: error))
        }
}


// MARK: - SessionProvider

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


// MARK: - SessionManager

/**
Handles the session.
*/
public class SessionManager {

    // Constants & enum
    public enum Notification: String {
        case Login = "SessionManager.Login"
        case Logout = "SessionManager.Logout"
        case KickedOut = "SessionManager.KickedOut"
    }

    // Manager & repositories
    private let apiClient: ApiClient
    private let websocketClient: WebSocketClient
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository

    // DAOs
    private let tokenDAO: TokenDAO
    private let deviceLocationDAO: DeviceLocationDAO
    private let favoritesDAO: FavoritesDAO

    // Router
    let webSocketCommandRouter = WebSocketCommandRouter(uuidGenerator: LGUUID())

    var reachability: ReachableNotifier?

    private let disposeBag = DisposeBag()
    
    public var loggedIn: Bool {
        return myUserRepository.myUser != nil && tokenDAO.token.level == .User
    }
    
    // MARK: - Lifecycle

    init(apiClient: ApiClient, websocketClient: WebSocketClient, locationManager: LocationManager, myUserRepository: MyUserRepository,
        installationRepository: InstallationRepository, tokenDAO: TokenDAO, deviceLocationDAO: DeviceLocationDAO,
        favoritesDAO: FavoritesDAO, reachability: ReachableNotifier?) {
            self.apiClient = apiClient
            self.websocketClient = websocketClient
            self.locationManager = locationManager
            self.myUserRepository = myUserRepository
            self.tokenDAO = tokenDAO
            self.deviceLocationDAO = deviceLocationDAO
            self.installationRepository = installationRepository
            self.favoritesDAO = favoritesDAO
            self.reachability = reachability
            configureReachability()
            setupRx()
    }


    // MARK: - Public methods

    /**
    Initializes `SessionManager`. Will cleanup tokens in case of clean installation
    */
    func initialize() {
        if installationRepository.installation == nil {
            //If there is no installation, we need to (re)create it, but first the token (if any) must be reseted.
            tokenDAO.reset()
        }
        if !loggedIn {
            logMessage(.Error, type: CoreLoggingOptions.Session, message: "Forced session cleanup (not logged in)")
            report(CoreReportSession.ForcedSessionCleanup, message: "Forced session cleanup (not logged in)")

            cleanSession()
        }
        installationRepository.updateIfChanged()
        myUserRepository.updateIfLocaleChanged()
    }
    
    func setupRx() {
        apiClient.renewingUser.asObservable().distinctUntilChanged().skip(1).subscribeNext { [weak self] renewing in
            if !renewing {
                self?.authenticateWebSocket(nil)
            } else {
               self?.websocketClient.suspendOperations()
            }
        }.addDisposableTo(disposeBag)
    }

    /**
    Signs up with the given credentials and public user name.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
    - parameter completion: The completion closure.
    */
    public func signUp(email: String, password: String, name: String, newsletter: Bool?,
        completion: ((Result<MyUser, SessionManagerError>) -> ())?) {

            logMessage(.Info, type: CoreLoggingOptions.Session, message: "Sign up email")

            let location = deviceLocationDAO.deviceLocation?.location
            let postalAddress = deviceLocationDAO.deviceLocation?.postalAddress
            myUserRepository.createWithEmail(email, password: password, name: name, newsletter: newsletter,
                location: location, postalAddress: postalAddress) {
                [weak self] createResult in
                    if let myUser = createResult.value {

                        let provider = UserSessionProvider.Email(email: email, password: password)
                        self?.authenticateUser(provider) { [weak self] authResult in
                            if let auth = authResult.value {
                                self?.setupAfterUserAuthentication(auth)
                                self?.setupSession(myUser)
                                completion?(Result<MyUser, SessionManagerError>(value: myUser))
                            }
                            else if let apiError = authResult.error {
                                let error = SessionManagerError(apiError: apiError)
                                completion?(Result<MyUser, SessionManagerError>(error: error))
                            }
                        }
                    } else if let error = createResult.error {
                        completion?(Result<MyUser, SessionManagerError>(error: SessionManagerError(apiError: error)))
                    }
            }
    }

    /**
    Logs the user in via email.
    - parameter email: The email.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    public func login(email: String, password: String, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        let provider: UserSessionProvider = .Email(email: email, password: password)
        login(provider, completion: completion)
    }

    /**
    Logs the user in via Facebook.
    - parameter token: The Facebook token.
    - parameter completion: The completion closure.
    */
    public func loginFacebook(token: String, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        let provider: UserSessionProvider = .Facebook(facebookToken: token)
        login(provider, completion: completion)
    }
    
    /**
     Logs the user in via Google
     
     - parameter token:      The Google token
     - parameter completion: The completion closure
     */
    public func loginGoogle(token: String, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        let provider: UserSessionProvider = .Google(googleToken: token)
        login(provider, completion: completion)
    }

    /**
    Requests a password recovery.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func recoverPassword(email: String, completion: ((Result<Void, SessionManagerError>) -> ())?) {
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Recover password")

        let request = SessionRouter.RecoverPassword(email: email)
        let decoder: AnyObject -> Void? = { object in return Void() }
        apiClient.request(request, decoder: decoder) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    /**
    Logs the user out.
    */
    public func logout() {
        if let userToken = tokenDAO.token.value?.componentsSeparatedByString(" ").last
            where tokenDAO.level >= .User {
                let request = SessionRouter.Delete(userToken: userToken)
                apiClient.request(request, decoder: {$0}, completion: nil)
        }
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Log out")

        tearDownSession(kicked: false)
        disconnectChat()
    }


    /**
    Connects the chat (will be done automatically too after login, startup)
    */
    public func connectChat(completion: (Result<Void, SessionManagerError> -> ())?) {
        guard LGCoreKit.activateWebsocket else { return }

        // WebsocketClient will call directly to completion if already connected
        websocketClient.startWebSocket(EnvironmentProxy.sharedInstance.webSocketURL) { [weak self] in
            self?.authenticateWebSocket(completion)
        }
    }

    /*
    Disconnects the chat
    */
    public func disconnectChat() {
        websocketClient.closeWebSocket(nil)
    }


    // MARK: - Internal methods

    /**
     Authenticates (or creates if needed) the given installation.
     - parameter completion:    The completion closure.
    */
    func authenticateInstallation(completion: (Result<Installation, ApiError> -> ())?) {
        authenticateInstallation(createIfNotFound: true, completion: completion)
    }

    /**
     Renews the user token.
     
     Note: Should be only called by `ApiClient` and `WebSocketClient`

     - parameter completion:    The completion closure.
    */
    func renewUserToken(completion: (Result<Authentication, ApiError> -> ())?) {
        guard let userToken = tokenDAO.get(level: .User),
            userTokenValue = userToken.value?.componentsSeparatedByString(" ").last else {
            completion?(Result<Authentication, ApiError>(error: .Internal(description: "Missing user token")))
            return
        }

        apiClient.requestRenewUserToken(userTokenValue, decoder: SessionManager.authDecoder) { [weak self] result in
            if let auth = result.value {
                self?.setupAfterUserAuthentication(auth)
                completion?(Result<Authentication, ApiError>(value: auth))
            }
            else if let error = result.error {
                completion?(Result<Authentication, ApiError>(error: error))
            }
        }
    }

    /**
    Sets up after logging-out.
    */
    func tearDownSession(kicked kicked: Bool) {
        cleanSession()
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.Logout.rawValue, object: nil)
        if kicked {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.KickedOut.rawValue, object: nil)
        }
    }

    func authenticateWebSocket(completion: (Result<Void, SessionManagerError> -> ())?) {
        let tokenString = tokenDAO.token.value?.componentsSeparatedByString(" ").last
        guard let token = tokenString where tokenDAO.level >= .User else {
            completion?(Result<Void, SessionManagerError>(error: .Unauthorized))
            return
        }
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(Result<Void, SessionManagerError>(error: .Unauthorized))
            return
        }

        let request = webSocketCommandRouter.authenticate(userId, authToken: token)
        websocketClient.sendCommand(request) { result in
            if let error = result.error {
                completion?(Result<Void, SessionManagerError>(error: SessionManagerError(webSocketError: error)))
            } else {
                completion?(Result<Void, SessionManagerError>(value: ()))
            }
        }
    }


    // MARK: - Private methods

    private func configureReachability() {
        guard let _ = reachability else { return }
        reachability?.onReachable = { [weak self] in
            self?.connectChat(nil)
        }
        reachability?.start()
    }

    // MARK: > Installation authentication

    /**
     Authenticate the given installation.
     - parameter createIfNotFound:  When true, after authenticating if the Installation is not found it will try to
                                    create an Installation and if successful will try to authenticate again.
     - parameter completion:        The completion closure.
     */
    private func authenticateInstallation(createIfNotFound createIfNotFound: Bool,
                                          completion: (Result<Installation, ApiError> -> ())?) {
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Authenticate installation")

        let request = SessionRouter.CreateInstallation(installationId: installationRepository.installationId)
        apiClient.request(request, decoder: SessionManager.authDecoder) { [weak self] authResult in
            if let auth = authResult.value {
                self?.setupAfterInstallationAuthentication(auth, completion: completion)
            } else if let error = authResult.error {
                guard createIfNotFound else {
                    completion?(Result<Installation, ApiError>(error: error))
                    return
                }

                switch error {
                case .Network, .Internal, .BadRequest, .Unauthorized, .Forbidden, .Conflict, .Scammer, .UnprocessableEntity,
                     .InternalServerError, .NotModified, .TooManyRequests, .UserNotVerified, .Other:
                    completion?(Result<Installation, ApiError>(error: error))
                case .NotFound:
                    logMessage(.Info, type: CoreLoggingOptions.Session, message: "Installation not found")
                    self?.createAndAuthenticateInstallation(completion)
                }
            }
        }
    }

    /**
     Creates an installation and if successful then authenticates it.
     - parameter completion:   The completion closure.
    */
    private func createAndAuthenticateInstallation(completion: (Result<Installation, ApiError> -> ())?) {
        installationRepository.create { [weak self] result in
            if let _ = result.value {
                self?.authenticateInstallation(createIfNotFound: false, completion: completion)
            } else if let error = result.error {
                completion?(Result<Installation, ApiError>(error: error))
            }
        }
    }

    /**
     Sets up after authenticating an installation.
     - parameter auth:          The authentication.
     - parameter completion:    The completion closure.
     */
    private func setupAfterInstallationAuthentication(auth: Authentication,
                                                      completion: (Result<Installation, ApiError> -> ())?) {
        // auth is not including "Bearer ", so we include it manually
        let value = "Bearer " + auth.token
        let installationToken = Token(value: value, level: .Installation)
        tokenDAO.save(installationToken)

        // If the installation is cached then there's no need to update/retrieve it, otherwise update it
        if let installation = installationRepository.installation {
            completion?(Result<Installation, ApiError>(value: installation))
        } else {
            installationRepository.update(completion)
        }
    }


    // MARK: > User authentication

    /**
     Authenticates the user with the given provider.
     - parameter provider: The session provider.
     - parameter completion: The completion closure.
     */
    private func authenticateUser(provider: UserSessionProvider,
                                  completion: ((Result<Authentication, ApiError>) -> ())?) {
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Authenticate user")

        let request = SessionRouter.CreateUser(provider: provider)
        apiClient.request(request, decoder: SessionManager.authDecoder, completion: completion)
    }

    /**
    Authenticates the user and retrieves it.
    - parameter provider: The session provider.
    - parameter completion: The completion closure.
    */
    private func login(provider: UserSessionProvider, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Log in \(provider.accountProvider.rawValue)")

        authenticateUser(provider) { [weak self] authResult in
            if let auth = authResult.value {
                self?.setupAfterUserAuthentication(auth)
                self?.myUserRepository.show(auth.id, completion: { [weak self] userShowResult in
                    if let myUser = userShowResult.value {
                        self?.setupSession(myUser)
                        completion?(Result<MyUser, SessionManagerError>(value: myUser))
                    } else if let error = userShowResult.error {
                        self?.tokenDAO.deleteUserToken()
                        completion?(Result<MyUser, SessionManagerError>(error: SessionManagerError(repositoryError: error)))
                    }
                })
            } else if let apiError = authResult.error {
                let error = SessionManagerError(apiError: apiError)
                completion?(Result<MyUser, SessionManagerError>(error: error))
            }
        }
    }

    /**
     Sets up after logging-in.
     - parameter myUser: My user.
     - parameter provider: The session provider.
     */
    private func setupSession(myUser: MyUser) {
        myUserRepository.save(myUser)
        myUserRepository.updateIfLocaleChanged()
        LGCoreKit.setupAfterLoggedIn {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.Login.rawValue, object: nil)
        }

        connectChat(nil)
    }

    /**
     Sets up after authenticating a user.
     - parameter auth: The authentication.
     */
    private func setupAfterUserAuthentication(auth: Authentication) {
        // auth is not including "Bearer ", so we include it manually
        let value = "Bearer " + auth.token
        let userToken = Token(value: value, level: .User)
        tokenDAO.save(userToken)
    }


    // MARK: > Session cleanup

    /**
     Cleans the session. Erases all user related stuff.
    */
    private func cleanSession() {
        logMessage(.Verbose, type: CoreLoggingOptions.Session, message: "Session cleaned up")
        tokenDAO.deleteUserToken()
        myUserRepository.deleteUser()
        favoritesDAO.clean()
    }


    // MARK: > Decoding

    /**
     Sets up after logging-in.
     - parameter myUser: My user.
     - parameter provider: The session provider.
     */
    private static func authDecoder(object: AnyObject) -> Authentication? {
        let json = JSON(object)
        return LGAuthentication.decode(json).value
    }
}
