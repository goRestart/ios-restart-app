//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 16/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Result


// MARK: - SessionManagerError

public enum SessionManagerError: ErrorType {

    case Network
    case NotFound
    case Unauthorized
    case AlreadyExists
    case Scammer
    case NonExistingEmail
    case Internal(message: String)

    public init(apiError: ApiError) {
        switch apiError {
        case .Network:
            self = .Network
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case .AlreadyExists:
            self = .AlreadyExists
        case .UnprocessableEntity:
            self = .NonExistingEmail
        case .Scammer:
            self = .Scammer
        case .InternalServerError:
            self = .Internal(message: "Internal Server Error")
        case .Internal, .NotModified:
            self = .Internal(message: "Internal API Error")
        }
    }

    public init(repositoryError: RepositoryError) {
        switch repositoryError {
        case .Network:
            self = .Network
        case .Unauthorized:
            self = .Unauthorized
        case .NotFound:
            self = .NotFound
        case let .Internal(message):
            self = .Internal(message: message)
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
Defines the session providers in letgo API.
*/
enum SessionProvider {
    case ParseUser(parseToken: String)
    case Email(email: String, password: String)
    case PwdRecovery(email: String)
    case Facebook(facebookToken: String)
    case Google(googleToken: String)

    var authProvider: AuthenticationProvider {
        switch self {
        case .ParseUser, .PwdRecovery:
            return .Unknown
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
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let chatRepository: ChatRepository
    
    // DAOs
    private let tokenDAO: TokenDAO
    private let deviceLocationDAO: DeviceLocationDAO
    private let favoritesDAO: FavoritesDAO

    public var loggedIn: Bool {
        return myUserRepository.myUser != nil && tokenDAO.token.level == .User
    }
    
    // MARK: - Lifecycle

    init(apiClient: ApiClient, locationManager: LocationManager, myUserRepository: MyUserRepository,
        installationRepository: InstallationRepository, chatRepository: ChatRepository, tokenDAO: TokenDAO, deviceLocationDAO: DeviceLocationDAO,
        favoritesDAO: FavoritesDAO) {
            self.apiClient = apiClient
            self.locationManager = locationManager
            self.myUserRepository = myUserRepository
            self.tokenDAO = tokenDAO
            self.deviceLocationDAO = deviceLocationDAO
            self.installationRepository = installationRepository
            self.chatRepository = chatRepository
            self.favoritesDAO = favoritesDAO
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

                        let provider = SessionProvider.Email(email: email, password: password)
                        self?.authenticate(provider) { [weak self] authResult in
                            if let auth = authResult.value {
                                self?.setupAfterAuthentication(auth)
                                self?.setupSetupSession(myUser, provider: provider)
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
    
    public func authenticateWebSocket(completion: (Result<Void, SessionManagerError> -> ())?) {
        let tokenString = tokenDAO.token.value?.componentsSeparatedByString(" ").last
        guard let token = tokenString where tokenDAO.level >= .User else { return }
        chatRepository.authenticate(token) { result in
            if let _ = result.value {
                completion?(Result<Void, SessionManagerError>(value: ()))
            } else {
                // TODO: Better error handling from WebSocketError
                completion?(Result<Void, SessionManagerError>(error: .Unauthorized))
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
        let provider: SessionProvider = .Email(email: email, password: password)
        login(provider, completion: completion)
    }

    /**
    Logs the user in via Facebook.
    - parameter token: The Facebook token.
    - parameter completion: The completion closure.
    */
    public func loginFacebook(token: String, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        let provider: SessionProvider = .Facebook(facebookToken: token)
        login(provider, completion: completion)
    }
    
    
    /**
     Logs the user in via Google
     
     - parameter token:      The Google token
     - parameter completion: The completion closure
     */
    public func loginGoogle(token: String, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        let provider: SessionProvider = .Google(googleToken: token)
        login(provider, completion: completion)
    }

    /**
    Requests a password recovery.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func recoverPassword(email: String, completion: ((Result<Void, SessionManagerError>) -> ())?) {
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Recover password")

        let provider: SessionProvider = .PwdRecovery(email: email)
        let request = SessionRouter.Create(sessionProvider: provider)
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
    }


    // MARK: - Internal methods

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
    
    private func cleanSession() {
        logMessage(.Verbose, type: CoreLoggingOptions.Session, message: "Session cleaned up")
        tokenDAO.deleteUserToken()
        myUserRepository.deleteUser()
        favoritesDAO.clean()
    }
    

    // MARK: - Private methods

    /**
    Authenticates the user with the given provider and saves the token if succesful.
    - parameter provider: The session provider.
    - parameter completion: The completion closure.
    */
    private func authenticate(provider: SessionProvider,
        completion: ((Result<Authentication, ApiError>) -> ())?) {
            let request = SessionRouter.Create(sessionProvider: provider)
            apiClient.request(request, decoder: self.decoder, completion: completion)
    }

    /**
    Authenticates the user and retrieves it.
    - parameter provider: The session provider.
    - parameter completion: The completion closure.
    */
    private func login(provider: SessionProvider, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        logMessage(.Info, type: CoreLoggingOptions.Session, message: "Log in \(provider.authProvider.rawValue)")

        authenticate(provider) { [weak self] authResult in
            if let auth = authResult.value {
                self?.setupAfterAuthentication(auth)
                self?.myUserRepository.show(auth.myUserId, completion: { [weak self] userShowResult in
                    if let myUser = userShowResult.value {
                        self?.setupSetupSession(myUser, provider: provider)
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
    Decodes an object to a `MyUser` object.
    - parameter object: The object.
    - returns: A `MyUser` object.
    */
    private func decoder(object: AnyObject) -> Authentication? {
        let json = JSON.parse(object)
        return LGAuthentication.decode(json).value
    }

    /**
    Sets up after authenticating.
    - parameter auth: The authentication.
    */
    private func setupAfterAuthentication(auth: Authentication) {
        // auth is not including "Bearer ", so we include it manually
        let value = "Bearer " + auth.token
        let userToken = Token(value: value, level: .User)
        tokenDAO.save(userToken)
    }

    /**
    Sets up after logging-in.
    - parameter myUser: My user.
    - parameter provider: The session provider.
    */
    private func setupSetupSession(myUser: MyUser, provider: SessionProvider) {
        let newUser = myUser.myUserWithNewAuthProvider(provider.authProvider)
        myUserRepository.save(newUser)
        LGCoreKit.setupAfterLoggedIn {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.Login.rawValue, object: nil)
        }
        
        // TODO: Uncomment when websocket chat is ready!
//         authenticateWebSocket(nil)
    }
}
