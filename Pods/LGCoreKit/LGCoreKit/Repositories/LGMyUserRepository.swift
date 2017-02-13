//
//  LGMyUserRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import JWT
import RxSwift

class LGMyUserRepository: InternalMyUserRepository {
    let dataSource: MyUserDataSource
    let dao: MyUserDAO
    
    let locale: Locale
    
    
    // MARK: - Lifecycle
    
    init(dataSource: MyUserDataSource, dao: MyUserDAO, locale: Locale) {
        self.dataSource = dataSource
        self.dao = dao
        self.locale = locale
    }
    
    
    // MARK: - MyUserRepository methods
    
    /**
     Returns the logged user.
     */
    var myUser: MyUser? {
        return dao.myUser
    }
    var rx_myUser: Observable<MyUser?> {
        return dao.rx_myUser
    }
    
    
    /**
     Updates the name of my user.
     - parameter myUserId: My user identifier.
     - parameter name: The name.
     - parameter completion: The completion closure.
     */
    func updateName(_ name: String, completion: MyUserCompletion?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: Any] = [JSONKeys.name: name]
        update(params, completion: completion)
    }
    
    /**
     Updates the password of my user.
     - parameter myUserId: My user identifier.
     - parameter password: The password.
     - parameter completion: The completion closure.
     */
    func updatePassword(_ password: String, completion: MyUserCompletion?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: Any] = [JSONKeys.password: password]
        update(params, completion: completion)
    }
    
    /**
     Updates the password of the given userId using the given token as Authentication
     
     - parameter password:   New password
     - parameter token:      Token to be used as Authentication
     - parameter completion: Completion closure
     */
    func resetPassword(_ password: String, token: String, completion: MyUserCompletion?) {
        
        guard let payload = try? JWT.decode(token, algorithm: .hs256(Data()), verify: false) else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Invalid token")))
            return
        }
        guard let userId = (payload["sub"] as? String)?.components(separatedBy: ":").first else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Invalid token")))
            return
        }
        
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: Any] = [JSONKeys.objectId: userId, JSONKeys.password: password]
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
    func updateEmail(_ email: String, completion: MyUserCompletion?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        let params: [String: Any] = [JSONKeys.email: email]
        update(params, completion: completion)
    }
    
    /**
     Updates the avatar of my user.
     - parameter avatar: The avatar.
     - parameter completion: The completion closure.
     */
    func updateAvatar(_ avatar: Data, progressBlock: ((Int) -> ())?, completion: MyUserCompletion?) {
        uploadAvatar(avatar, progressBlock: progressBlock, completion: completion)
    }
    
    
    // MARK: - InternalMyUserRepository methods
    
    /**
     Creates a `MyUser` with the given credentials, user name and location.
     - parameter email: The email.
     - parameter password: The password.
     - parameter name: The name.
     - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter completion: The completion closure. Will pass api error as the method is internal so that the caller can
     have the complete error information
     */
    func createWithEmail(_ email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
                         postalAddress: PostalAddress?, completion: ((Result<MyUser, ApiError>) -> ())?) {
        dataSource.createWithEmail(email, password: password, name: name, newsletter: newsletter,
                                   location: location, postalAddress: postalAddress,
                                   localeIdentifier: locale.identifier, completion: completion)
    }
    
    /**
     Links an email account with the logged in user
     
     - parameter email:      email to be linked
     - parameter completion: completion closure
     */
    func linkAccount(_ email: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        linkAccount(.email(email: email), completion: completion)
    }
    
    /**
     Links a facebook account with the logged in user
     
     - parameter email:      facebook token of the account to be linked
     - parameter completion: completion closure
     */
    func linkAccountFacebook(_ token: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        linkAccount(.facebook(facebookToken: token), completion: completion)
    }
    
    /**
     Links a google account with the logged in user
     
     - parameter email:      google token of the account to be linked
     - parameter completion: completion closure
     */
    func linkAccountGoogle(_ token: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        linkAccount(.google(googleToken: token), completion: completion)
    }
    
    /**
     Retrieves my user.
     - parameter myUserId: My user identifier.
     - parameter completion: The completion closure.
     */
    func show(_ myUserId: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        dataSource.show(myUserId) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }
    
    func refresh(_ completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
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
        
        var params: [String: Any] = [:]
        if myUser.localeIdentifier != locale.identifier {
            params[JSONKeys.localeIdentifier] = locale.identifier
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
    func updateLocation(_ location: LGLocation, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        var params = [String: Any]()
        params[JSONKeys.latitude] = location.coordinate.latitude
        params[JSONKeys.longitude] = location.coordinate.longitude
        params[JSONKeys.locationType] = location.type.rawValue
        params[JSONKeys.zipCode] = location.postalAddress?.zipCode ?? ""
        params[JSONKeys.address] = location.postalAddress?.address ?? ""
        params[JSONKeys.city] = location.postalAddress?.city ?? ""
        params[JSONKeys.state] = location.postalAddress?.state ?? ""
        params[JSONKeys.countryCode] = location.postalAddress?.countryCode ?? ""
        update(params, completion: completion)
    }
    
    /**
     Saves the given `MyUser`.
     - parameter myUser: My user.
     */
    func save(_ myUser: MyUser) {
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
    private func update(_ params: [String: Any], completion: MyUserCompletion?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
            return
        }
        let JSONKeys = LGMyUser.ApiMyUserKeys()
        var paramsWithId = params
        paramsWithId[JSONKeys.objectId] = myUserId
        dataSource.update(myUserId, params: paramsWithId) { [weak self] result in
            guard self?.myUser != nil else {
                completion?(Result<MyUser, RepositoryError>(error:
                    .internalError(message: "User logged out while waiting for response")))
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
    private func uploadAvatar(_ avatar: Data, progressBlock: ((Int) -> ())?,
                              completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
            return
        }
        dataSource.uploadAvatar(avatar, myUserId: myUserId, progressBlock: progressBlock) {
            [weak self] (result: Result<MyUser, ApiError>) -> () in
            handleApiResult(result, success: self?.save, completion: completion)
        }
    }
    
    private func linkAccount(_ provider: LinkAccountProvider, completion:((Result<MyUser, RepositoryError>) -> ())?) {
        guard let myUserId = myUser?.objectId else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
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
