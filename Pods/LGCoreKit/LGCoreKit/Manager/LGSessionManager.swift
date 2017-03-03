//
//  LGSessionManager.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

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


// MARK: - HOF

/**
 Handles the given API result and executes a completion with a `SessionManagerError`.
 - parameter result: The result to handle.
 - parameter success: A completion block that is executed only on successful result.
 - parameter completion: A completion block that is executed on both successful & failure result.
 */
func handleApiResult<T>(_ result: Result<T, ApiError>, completion: ((Result<T, SessionManagerError>) -> ())?) {
    handleApiResult(result, success: nil, failed: nil, completion: completion)
}

func handleApiResult<T>(_ result: Result<T, ApiError>,
                     success: ((T) -> ())?,
                     completion: ((Result<T, SessionManagerError>) -> ())?) {
    handleApiResult(result, success: success, failed: nil, completion: completion)
}

func handleApiResult<T>(_ result: Result<T, ApiError>,
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



// MARK: - SessionManager

/**
 Handles the session.
 */
class LGSessionManager: InternalSessionManager {

    var sessionEvents: Observable<SessionEvent> {
        return events
    }

    // Manager & repositories
    private let apiClient: ApiClient
    private let websocketClient: WebSocketClient
    private let myUserRepository: InternalMyUserRepository
    private let installationRepository: InternalInstallationRepository

    // DAOs
    private let tokenDAO: TokenDAO
    private let deviceLocationDAO: DeviceLocationDAO
    private let favoritesDAO: FavoritesDAO

    // Router
    let webSocketCommandRouter = WebSocketCommandRouter(uuidGenerator: LGUUID())

    private let events = PublishSubject<SessionEvent>()
    private let disposeBag = DisposeBag()

    var loggedIn: Bool {
        return myUserRepository.myUser != nil && tokenDAO.token.level == .user
    }

    // MARK: - Lifecycle

    init(apiClient: ApiClient, websocketClient: WebSocketClient, myUserRepository: InternalMyUserRepository,
         installationRepository: InternalInstallationRepository, tokenDAO: TokenDAO, deviceLocationDAO: DeviceLocationDAO,
         favoritesDAO: FavoritesDAO) {
        self.apiClient = apiClient
        self.websocketClient = websocketClient
        self.myUserRepository = myUserRepository
        self.tokenDAO = tokenDAO
        self.deviceLocationDAO = deviceLocationDAO
        self.installationRepository = installationRepository
        self.favoritesDAO = favoritesDAO
        
        setupWebSocketRx()
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
            logMessage(.error, type: CoreLoggingOptions.session, message: "Forced session cleanup (not logged in)")
            report(CoreReportSession.forcedSessionCleanup, message: "Forced session cleanup (not logged in)")

            cleanSession()
        }
        installationRepository.updateIfChanged()
        myUserRepository.updateIfLocaleChanged()
        
        startChat()
    }

    /**
     Signs up with the given credentials and user name.
     - parameter email: The email.
     - parameter password: The password.
     - parameter name: The name.
     - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
     - parameter completion: The completion closure.
     */
    func signUp(_ email: String, password: String, name: String, newsletter: Bool?,
                       completion: SessionMyUserCompletion?) {

        logMessage(.info, type: CoreLoggingOptions.session, message: "Sign up email")

        let location = deviceLocationDAO.deviceLocation?.location
        let postalAddress = deviceLocationDAO.deviceLocation?.postalAddress
        myUserRepository.createWithEmail(email, password: password, name: name, newsletter: newsletter,
                                         location: location, postalAddress: postalAddress) {
                                            [weak self] createResult in
                                            if let myUser = createResult.value {

                                                let provider = UserSessionProvider.email(email: email, password: password)
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
     Signs up with the given credentials and user name, if recaptcha verification is ok.
     - parameter email: The email.
     - parameter password: The password.
     - parameter name: The name.
     - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
     - parameter recaptchaToken: Recaptcha token.
     - parameter completion: The completion closure.
     */
    func signUp(_ email: String, password: String, name: String, newsletter: Bool?, recaptchaToken: String,
                       completion: SessionMyUserCompletion?) {
        verifyWithRecaptcha(recaptchaToken) { [weak self] result in
            if let _ = result.value {
                self?.signUp(email, password: password, name: name, newsletter: newsletter, completion: completion)
            } else if let apiError = result.error {
                let error = SessionManagerError(apiError: apiError)
                completion?(Result<MyUser, SessionManagerError>(error: error))
            }
        }
    }

    /**
     Logs the user in via email.
     - parameter email: The email.
     - parameter password: The password.
     - parameter completion: The completion closure.
     */
    func login(_ email: String, password: String, completion: SessionMyUserCompletion?) {
        let provider: UserSessionProvider = .email(email: email, password: password)
        login(provider, completion: completion)
    }

    /**
     Logs the user in via Facebook.
     - parameter token: The Facebook token.
     - parameter completion: The completion closure.
     */
    func loginFacebook(_ token: String, completion: SessionMyUserCompletion?) {
        let provider: UserSessionProvider = .facebook(facebookToken: token)
        login(provider, completion: completion)
    }

    /**
     Logs the user in via Google

     - parameter token:      The Google token
     - parameter completion: The completion closure
     */
    func loginGoogle(_ token: String, completion: SessionMyUserCompletion?) {
        let provider: UserSessionProvider = .google(googleToken: token)
        login(provider, completion: completion)
    }

    /**
     Requests a password recovery.
     - parameter email: The email.
     - parameter completion: The completion closure.
     */
    func recoverPassword(_ email: String, completion: SessionEmptyCompletion?) {
        logMessage(.info, type: CoreLoggingOptions.session, message: "Recover password")

        let request = SessionRouter.recoverPassword(email: email)
        let decoder: (Any) -> Void? = { object in return Void() }
        apiClient.request(request, decoder: decoder) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    /**
     Logs the user out.
     */
    func logout() {
        if let userToken = tokenDAO.token.actualValue, tokenDAO.level >= .user {
            let request = SessionRouter.delete(userToken: userToken)
            apiClient.request(request, decoder: {$0}, completion: nil)
        }
        logMessage(.info, type: CoreLoggingOptions.session, message: "Log out")

        tearDownSession(kicked: false)
    }

    /**
     Starts the chat, will open websocket and authenticate on demand
     */
    func startChat() {
        guard LGCoreKit.shouldUseChatWithWebSocket else { return }
        guard loggedIn else { return }
        websocketClient.start(withEndpoint: EnvironmentProxy.sharedInstance.webSocketURL)
    }

    /**
     Stops the chat removing any pending completion / operation
     */
    dynamic func stopChat() {
        guard LGCoreKit.shouldUseChatWithWebSocket else { return }
        websocketClient.stop()
    }


    // MARK: - Internal methods

    /**
     Authenticates (or creates if needed) the given installation.
     - parameter completion:    The completion closure.
     */
    func authenticateInstallation(_ completion: ((Result<Installation, ApiError>) -> ())?) {
        authenticateInstallation(createIfNotFound: true, completion: completion)
    }

    /**
     Renews the user token.

     Note: Should be only called by `ApiClient` and `WebSocketClient`

     - parameter completion:    The completion closure.
     */
    func renewUserToken(_ completion: ((Result<Authentication, ApiError>) -> ())?) {
        guard let userToken = tokenDAO.get(level: .user),
            let userTokenValue = userToken.actualValue else {
                completion?(Result<Authentication, ApiError>(error: .internalError(description: "Missing user token")))
                return
        }

        apiClient.requestRenewUserToken(userTokenValue, decoder: LGSessionManager.authDecoder) { [weak self] result in
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
    func tearDownSession(kicked: Bool) {
        let previouslyLogged = loggedIn
        cleanSession()
        if previouslyLogged {
            events.onNext(.logout(kickedOut: kicked))
        }
        stopChat()
    }

    func authenticateWebSocket() {
        guard LGCoreKit.shouldUseChatWithWebSocket else { return }
        let tokenString = tokenDAO.token.actualValue
        guard let token = tokenString, tokenDAO.level >= .user,
            let userId = myUserRepository.myUser?.objectId else {
                // Session manager can not authenticate, suspend and cancel all operations
                websocketClient.suspendOperations()
                websocketClient.cancelAllOperations()
                return
        }

        let request = webSocketCommandRouter.authenticate(userId, authToken: token)
        websocketClient.sendCommand(request, completion: nil)
    }

    private func setupWebSocketRx() {
        apiClient.renewingUser.asObservable().distinctUntilChanged().skip(1).subscribeNext { [weak self] renewing in
            if !renewing {
                self?.authenticateWebSocket()
            } else {
                self?.websocketClient.suspendOperations()
            }
            }.addDisposableTo(disposeBag)
    }

    // MARK: > Installation authentication

    /**
     Authenticate the given installation.
     - parameter createIfNotFound:  When true, after authenticating if the Installation is not found it will try to
     create an Installation and if successful will try to authenticate again.
     - parameter completion:        The completion closure.
     */
    private func authenticateInstallation(createIfNotFound: Bool,
                                                           completion: ((Result<Installation, ApiError>) -> ())?) {
        logMessage(.info, type: CoreLoggingOptions.session, message: "Authenticate installation")

        let request = SessionRouter.createInstallation(installationId: installationRepository.installationId)
        apiClient.request(request, decoder: LGSessionManager.authDecoder) { [weak self] authResult in
            if let auth = authResult.value {
                self?.setupAfterInstallationAuthentication(auth, completion: completion)
            } else if let error = authResult.error {
                guard createIfNotFound else {
                    completion?(Result<Installation, ApiError>(error: error))
                    return
                }

                switch error {
                case .network, .internalError, .badRequest, .unauthorized, .forbidden, .conflict, .scammer, .unprocessableEntity,
                     .internalServerError, .notModified, .tooManyRequests, .userNotVerified, .other:
                    completion?(Result<Installation, ApiError>(error: error))
                case .notFound:
                    logMessage(.info, type: CoreLoggingOptions.session, message: "Installation not found")
                    self?.createAndAuthenticateInstallation(completion)
                }
            }
        }
    }

    /**
     Creates an installation and if successful then authenticates it.
     - parameter completion:   The completion closure.
     */
    private func createAndAuthenticateInstallation(_ completion: ((Result<Installation, ApiError>) -> ())?) {
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
    private func setupAfterInstallationAuthentication(_ auth: Authentication,
                                                      completion: ((Result<Installation, ApiError>) -> ())?) {
        // auth is not including "Bearer ", so we include it manually
        let value = "Bearer " + auth.token
        let installationToken = Token(value: value, level: .installation)
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
    private func authenticateUser(_ provider: UserSessionProvider,
                                  completion: ((Result<Authentication, ApiError>) -> ())?) {
        logMessage(.info, type: CoreLoggingOptions.session, message: "Authenticate user")

        let request = SessionRouter.createUser(provider: provider)
        apiClient.request(request, decoder: LGSessionManager.authDecoder, completion: completion)
    }

    /**
     Authenticates the user and retrieves it.
     - parameter provider: The session provider.
     - parameter completion: The completion closure.
     */
    private func login(_ provider: UserSessionProvider, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        logMessage(.info, type: CoreLoggingOptions.session, message: "Log in \(provider.accountProvider.rawValue)")

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
    private func setupSession(_ myUser: MyUser) {
        myUserRepository.save(myUser)
        myUserRepository.updateIfLocaleChanged()
        LGCoreKit.setupAfterLoggedIn { [weak self] in
            self?.events.onNext(.login)
        }
        startChat()
    }

    /**
     Sets up after authenticating a user.
     - parameter auth: The authentication.
     */
    private func setupAfterUserAuthentication(_ auth: Authentication) {
        // auth is not including "Bearer ", so we include it manually
        let value = "Bearer " + auth.token
        let userToken = Token(value: value, level: .user)
        tokenDAO.save(userToken)
    }


    // MARK: > Verify

    private func verifyWithRecaptcha(_ recaptchaToken: String, completion: ((Result<Void, ApiError>) -> ())?) {
        logMessage(.info, type: CoreLoggingOptions.session, message: "Verify with recaptcha")

        let request = SessionRouter.verify(recaptchaToken: recaptchaToken)
        apiClient.request(request, decoder: LGSessionManager.authDecoder) { [weak self] result in
            if let auth = result.value, let authLevel = auth.token.tokenAuthLevel {
                switch authLevel {
                case .installation:
                    self?.setupAfterInstallationAuthentication(auth, completion: nil)
                    completion?(Result<Void, ApiError>(value: Void()))
                case .user:
                    self?.setupAfterUserAuthentication(auth)
                    completion?(Result<Void, ApiError>(value: Void()))
                case .nonexistent:
                    completion?(Result<Void, ApiError>(error: .internalError(description: "Received token w/o roles")))
                }
            } else if let error = result.error {
                completion?(Result<Void, ApiError>(error: error))
            }
        }
    }
    
    
    // MARK: > Session cleanup
    
    /**
     Cleans the session. Erases all user related stuff.
     */
    private func cleanSession() {
        logMessage(.verbose, type: CoreLoggingOptions.session, message: "Session cleaned up")
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
    private static func authDecoder(_ object: Any) -> Authentication? {
        let json = JSON(object)
        return LGAuthentication.decode(json).value
    }
}

