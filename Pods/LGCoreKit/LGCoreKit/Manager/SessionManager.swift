//
//  SessionManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 16/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Result
import Parse


// MARK: - SessionManagerError

public enum SessionManagerError: ErrorType {

    case Network
    case NotFound
    case Unauthorized
    case AlreadyExists
    case Scammer
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
        case .Scammer:
            self = .Scammer
        case .InternalServerError:
            self = .Internal(message: "Internal Server Error")
        case .Internal:
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

    var authProvider: AuthenticationProvider {
        switch self {
        case .ParseUser, .PwdRecovery:
            return .Unknown
        case .Email:
            return .Email
        case .Facebook:
            return .Facebook
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
    }

    // Singleton
    public static let sharedInstance: SessionManager = SessionManager()

    // Manager & repositories
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository

    // DAOs
    private let tokenDAO: TokenDAO
    private let deviceLocationDAO: DeviceLocationDAO
    private let favoritesDAO: FavoritesDAO

    // MARK: - Lifecycle

    convenience init() {
        let myUserRepository = MyUserRepository.sharedInstance
        let installationRepository = InstallationRepository.sharedInstance
        
        let locationManager = LocationManager.sharedInstance
        let tokenDAO = TokenKeychainDAO.sharedInstance
        let deviceLocationDAO = DeviceLocationUDDAO.sharedInstance
        let favoritesDAO = FavoritesUDDAO.sharedInstance
        
        self.init(locationManager: locationManager, myUserRepository: myUserRepository,
            installationRepository: installationRepository, tokenDAO: tokenDAO, deviceLocationDAO: deviceLocationDAO,
            favoritesDAO: favoritesDAO)
    }

    init(locationManager: LocationManager, myUserRepository: MyUserRepository,
        installationRepository: InstallationRepository, tokenDAO: TokenDAO, deviceLocationDAO: DeviceLocationDAO,
        favoritesDAO: FavoritesDAO) {
            self.locationManager = locationManager
            self.myUserRepository = myUserRepository
            self.tokenDAO = tokenDAO
            self.deviceLocationDAO = deviceLocationDAO
            self.installationRepository = installationRepository
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
    }

    /**
    Starts `SessionManager`.
    - paramter completion: The completion closure.
    */
    func start(completion: (() -> ())?) {
        runParseUserMigration(completion)
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

            let location = deviceLocationDAO.deviceLocation?.location
            myUserRepository.createWithEmail(email, password: password, name: name, newsletter: newsletter,
                location: location) {
                [weak self] createResult in
                    if let myUser = createResult.value {

                        let provider = SessionProvider.Email(email: email, password: password)
                        self?.authenticate(provider) { [weak self] authResult in
                            if let auth = authResult.value {
                                self?.setupAfterAuthentication(auth)
                                self?.setupAfterLoggedIn(myUser, provider: provider)
                                completion?(Result<MyUser, SessionManagerError>(value: myUser))
                            }
                            else if let apiError = authResult.error {
                                let error = SessionManagerError(apiError: apiError)
                                completion?(Result<MyUser, SessionManagerError>(error: error))
                            }
                        }
                    } else if let error = createResult.error {
                        completion?(Result<MyUser, SessionManagerError>(error: SessionManagerError(repositoryError: error)))
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
    Requests a password recovery.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func recoverPassword(email: String, completion: ((Result<Void, SessionManagerError>) -> ())?) {
        let provider: SessionProvider = .PwdRecovery(email: email)
        let request = SessionRouter.Create(sessionProvider: provider)
        let decoder: AnyObject -> Void? = { object in return Void() }
        ApiClient.request(request, decoder: decoder) { result in
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
                ApiClient.request(request, decoder: {$0}, completion: nil)
        }

        setupAfterLoggedOut()
    }


    // MARK: - Private methods

    /**
    Runs a parse user migration if the user was logged in via Parse.
    - parameter completion: The completion closure.
    */
    private func runParseUserMigration(completion: (() -> ())?) {
        guard let parseUser = PFUser.currentUser(), parseToken = parseUser.sessionToken else {
            completion?()
            return
        }
        guard !PFAnonymousUtils.isLinkedWithUser(parseUser) else {
            completion?()
            return
        }

        let provider = SessionProvider.ParseUser(parseToken: parseToken)
        let userRetrievalCompletion: (Result<MyUser, SessionManagerError>) -> () = { result in
            if let _ = result.value {
                PFUser.logOutInBackground()
            }
            completion?()
        }
        login(provider, completion: userRetrievalCompletion)
    }

    /**
    Authenticates the user with the given provider and saves the token if succesful.
    - parameter provider: The session provider.
    - parameter completion: The completion closure.
    */
    private func authenticate(provider: SessionProvider,
        completion: ((Result<Authentication, ApiError>) -> ())?) {
            let request = SessionRouter.Create(sessionProvider: provider)
            ApiClient.request(request, decoder: self.decoder, completion: completion)
    }

    /**
    Authenticates the user and retrieves it.
    - parameter provider: The session provider.
    - parameter completion: The completion closure.
    */
    private func login(provider: SessionProvider, completion: ((Result<MyUser, SessionManagerError>) -> ())?) {
        authenticate(provider) { [weak self] authResult in
            if let auth = authResult.value {
                self?.setupAfterAuthentication(auth)
                self?.myUserRepository.show(auth.myUserId, completion: { [weak self] userShowResult in
                    if let myUser = userShowResult.value {
                        self?.setupAfterLoggedIn(myUser, provider: provider)
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
    private func setupAfterLoggedIn(myUser: MyUser, provider: SessionProvider) {
        let newUser = myUser.myUserWithNewAuthProvider(provider.authProvider)
        myUserRepository.save(newUser)
        LGCoreKit.setupAfterLoggedIn {
            NSNotificationCenter.defaultCenter().postNotificationName(Notification.Login.rawValue, object: nil)
        }
    }

    /**
    Sets up after logging-out.
    */
    private func setupAfterLoggedOut() {
        tokenDAO.deleteUserToken()
        myUserRepository.deleteUser()
        favoritesDAO.clean()
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.Logout.rawValue, object: nil)
    }
}
