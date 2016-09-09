//
//  MyUserRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result
import JWT
import RxSwift

public typealias MyUserResult = Result<MyUser, RepositoryError>
public typealias MyUserCompletion = MyUserResult -> Void

public class MyUserRepository {
    let dataSource: MyUserDataSource
    let dao: MyUserDAO

    let locale: NSLocale


    // MARK: - Lifecycle

    init(dataSource: MyUserDataSource, dao: MyUserDAO, locale: NSLocale) {
        self.dataSource = dataSource
        self.dao = dao
        self.locale = locale
    }


    // MARK: - Public methods

    /**
    Returns the logged user.
    */
    public var myUser: MyUser? {
        return dao.myUser
    }
    public var rx_myUser: Variable<MyUser?> {
        return dao.rx_myUser
    }


    /**
    Updates the name of my user.
    - parameter myUserId: My user identifier.
    - parameter name: The name.
    - parameter completion: The completion closure.
    */
    public func updateName(name: String, completion: MyUserCompletion?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: AnyObject] = [JSONKeys.name: name]
        update(params, completion: completion)
    }

    /**
    Updates the password of my user.
    - parameter myUserId: My user identifier.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    public func updatePassword(password: String, completion: MyUserCompletion?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: AnyObject] = [JSONKeys.password: password]
        update(params, completion: completion)
    }
    
    /**
    Updates the password of the given userId using the given token as Authentication
    
    - parameter password:   New password
    - parameter token:      Token to be used as Authentication
    - parameter completion: Completion closure
    */
    public func resetPassword(password: String, token: String, completion: MyUserCompletion?) {
        
        guard let payload = try? JWT.decode(token, algorithm: .HS256(""), verify: false) else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Invalid token")))
            return
        }
        guard let userId = (payload["sub"] as? String)?.componentsSeparatedByString(":").first else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Invalid token")))
            return
        }

        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: AnyObject] = [JSONKeys.objectId: userId, JSONKeys.password: password]
        dataSource.resetPassword(userId, params: params, token: token) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    /**
    Updates the email of my user.
    - parameter myUserId: My user identifier.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func updateEmail(email: String, completion: MyUserCompletion?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: AnyObject] = [JSONKeys.email: email]
        update(params, completion: completion)
    }

    /**
    Updates the avatar of my user.
    - parameter avatar: The avatar.
    - parameter completion: The completion closure.
    */
    public func updateAvatar(avatar: NSData, progressBlock: ((Int) -> ())?, completion: MyUserCompletion?) {
        uploadAvatar(avatar, progressBlock: progressBlock, completion: completion)
    }


    // MARK: - Internal methods

    /**
    Creates a `MyUser` with the given credentials, public user name and location.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
    - parameter location: The location.
    - parameter postalAddress: The postal address.
    - parameter completion: The completion closure. Will pass api error as the method is internal so that the caller can
                            have the complete error information
    */
    func createWithEmail(email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
                         postalAddress: PostalAddress?, completion: ((Result<MyUser, ApiError>) -> ())?) {
            dataSource.createWithEmail(email, password: password, name: name, newsletter: newsletter,
                                       location: location, postalAddress: postalAddress,
                                       localeIdentifier: locale.localeIdentifier, completion: completion)
    }

    /**
     Links an email account with the logged in user

     - parameter email:      email to be linked
     - parameter completion: completion closure
     */
    public func linkAccount(email: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        linkAccount(.Email(email: email), completion: completion)
    }

    /**
     Links a facebook account with the logged in user

     - parameter email:      facebook token of the account to be linked
     - parameter completion: completion closure
     */
    public func linkAccountFacebook(token: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        linkAccount(.Facebook(facebookToken: token), completion: completion)
    }

    /**
     Links a google account with the logged in user

     - parameter email:      google token of the account to be linked
     - parameter completion: completion closure
     */
    public func linkAccountGoogle(token: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        linkAccount(.Google(googleToken: token), completion: completion)
    }

    /**
    Retrieves my user.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    func show(myUserId: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        dataSource.show(myUserId) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    func refresh(completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Missing MyUser objectId")))
            return
        }
        dataSource.show(myUserId) { [weak self] result in
            handleApiResult(result, success: self?.save, completion: completion)
        }
    }

    /**
     Updates the user if the locale changed.
     - returns: If the update was performed.
     */
    func updateIfLocaleChanged() -> Bool {
        guard let myUser = dao.myUser else { return false }

        let JSONKeys = LGMyUser.ApiMyUserKeys()

        var params: [String: AnyObject] = [:]
        if myUser.localeIdentifier != locale.localeIdentifier {
            params[JSONKeys.localeIdentifier] = locale.localeIdentifier
        }
        guard !params.isEmpty else { return false }

        update(params, completion: nil)
        return true
    }

    /**
    Updates the location of my user. If no postal address is passed-by it nullifies it.
    - parameter myUserId: My user identifier.
    - parameter location: The location.
    - parameter postalAddress: The postal address.
    - parameter completion: The completion closure.
    */
    func updateLocation(location: LGLocation, postalAddress: PostalAddress,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        var params = [String: AnyObject]()
        params[JSONKeys.latitude] = location.coordinate.latitude
        params[JSONKeys.longitude] = location.coordinate.longitude
        params[JSONKeys.locationType] = location.type?.rawValue
        params[JSONKeys.zipCode] = postalAddress.zipCode ?? ""
        params[JSONKeys.address] = postalAddress.address ?? ""
        params[JSONKeys.city] = postalAddress.city ?? ""
        params[JSONKeys.countryCode] = postalAddress.countryCode ?? ""
        update(params, completion: completion)
    }

    /**
    Saves the given `MyUser`.
    - parameter myUser: My user.
    */
    func save(myUser: MyUser) {
        dao.save(myUser)
    }

    /**
    Deletes the user.
    */
    func deleteUser() {
        dao.delete()
    }


    // MARK: - Private methods

    /**
    Updates a `MyUser` with the given parameters.
    - parameter params: The parameters to be updated.
    - parameter completion: The completion closure.
    */
    private func update(params: [String: AnyObject], completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Missing MyUser objectId")))
            return
        }
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        var paramsWithId = params
        paramsWithId[JSONKeys.objectId] = myUserId
        dataSource.update(myUserId, params: paramsWithId) { [weak self] result in
            guard self?.myUser != nil else {
                completion?(Result<MyUser, RepositoryError>(error:
                    .Internal(message: "User logged out while waiting for response")))
                return
            }
            handleApiResult(result, success: self?.save, completion: completion)
        }
    }

    /**
    Uploads a new user avatar.
    - parameter avatar: The avatar to be uploaded.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    private func uploadAvatar(avatar: NSData, progressBlock: ((Int) -> ())?,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            guard let myUserId = myUser?.objectId else {
                completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Missing MyUser objectId")))
                return
            }
            dataSource.uploadAvatar(avatar, myUserId: myUserId, progressBlock: progressBlock) {
                    [weak self] (result: Result<MyUser, ApiError>) -> () in
                    handleApiResult(result, success: self?.save, completion: completion)
            }
    }

    private func linkAccount(provider: LinkAccountProvider, completion:((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Missing MyUser objectId")))
            return
        }
        dataSource.linkAccount(myUserId, provider: provider) { [weak self] result in
            if let apiError = result.error {
                completion?(Result<MyUser, RepositoryError>(error: RepositoryError(apiError: apiError)))
            } else {
                self?.refresh(completion)
            }
        }
    }
}
