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


    // MARK: - Lifecycle

    public convenience init() {
        let myUserRepository = MyUserRepository.sharedInstance
        let installationRepository = InstallationRepository.sharedInstance

        let locationManager = LocationManager.sharedInstance
        let tokenDAO = TokenKeychainDAO.sharedInstance
        let deviceLocationDAO = DeviceLocationUDDAO.sharedInstance

        self.init(locationManager: locationManager, myUserRepository: myUserRepository, installationRepository: installationRepository, tokenDAO: tokenDAO,
            deviceLocationDAO: deviceLocationDAO)
    }

    init(locationManager: LocationManager, myUserRepository: MyUserRepository,
        installationRepository: InstallationRepository, tokenDAO: TokenDAO, deviceLocationDAO: DeviceLocationDAO) {
            self.locationManager = locationManager
            self.myUserRepository = myUserRepository
            self.tokenDAO = tokenDAO
            self.deviceLocationDAO = deviceLocationDAO
            self.installationRepository = installationRepository
    }


    // MARK: - Public methods

    /**
    Starts `SessionManager`.
    - paramter completion: The completion closure.
    */
    public func start(completion: (() -> ())?) {
        if installationRepository.installation == nil {
            //If there is no installation, we need to (re)create it, but first the token (if any) must be reseted.
            tokenDAO.reset()
        }
        runParseUserMigration(completion)
    }

    /**
    Signs up with the given credentials and public user name.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter completion: The completion closure.
    */
    public func signUp(email: String, password: String, name: String,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {

            let location = deviceLocationDAO.deviceLocation?.location
            myUserRepository.createWithEmail(email, password: password, name: name, location: location) {
                [weak self] createResult in
                    if let myUser = createResult.value {

                        let provider = SessionProvider.Email(email: email, password: password)
                        self?.authenticate(provider) { [weak self] authResult in
                            if let auth = authResult.value {
                                self?.setupAfterAuthentication(auth)
                                self?.setupAfterLoggedIn(myUser, provider: provider)
                                completion?(Result<MyUser, RepositoryError>(value: myUser))
                            }
                            else if let apiError = authResult.error {
                                let error = RepositoryError(apiError: apiError)
                                completion?(Result<MyUser, RepositoryError>(error: error))
                            }
                        }
                    }
                    else if let error = createResult.error {
                        completion?(Result<MyUser, RepositoryError>(error: error))
                    }
            }
    }

    /**
    Logs the user in via email.
    - parameter email: The email.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    public func login(email: String, password: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let provider: SessionProvider = .Email(email: email, password: password)
        login(provider, completion: completion)
    }

    /**
    Logs the user in via Facebook.
    - parameter token: The Facebook token.
    - parameter completion: The completion closure.
    */
    public func loginFacebook(token: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let provider: SessionProvider = .Facebook(facebookToken: token)
        login(provider, completion: completion)
    }

    /**
    Requests a password recovery.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func recoverPassword(email: String, completion: ((Result<Void, RepositoryError>) -> ())?) {
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
        let userRetrievalCompletion: (Result<MyUser, RepositoryError>) -> () = { result in
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
    private func login(provider: SessionProvider, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        authenticate(provider) { [weak self] authResult in
            if let auth = authResult.value {
                self?.setupAfterAuthentication(auth)
                self?.myUserRepository.show(auth.myUserId, completion: { [weak self] userShowResult in
                    if let myUser = userShowResult.value {
                        self?.setupAfterLoggedIn(myUser, provider: provider)
                    } else if let _ = userShowResult.error {
                        self?.tokenDAO.deleteUserToken()
                    }
                    completion?(userShowResult)
                })
            } else if let apiError = authResult.error {
                let error = RepositoryError(apiError: apiError)
                completion?(Result<MyUser, RepositoryError>(error: error))
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
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.Login.rawValue, object: nil)
    }

    /**
    Sets up after logging-out.
    */
    private func setupAfterLoggedOut() {
        tokenDAO.deleteUserToken()
        myUserRepository.deleteUser()
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.Logout.rawValue, object: nil)
    }
}
