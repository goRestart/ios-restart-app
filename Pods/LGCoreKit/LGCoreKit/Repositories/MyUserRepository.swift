//
//  MyUserRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

public class MyUserRepository {
    let dataSource: MyUserDataSource
    let dao: MyUserDAO

    // TODO: Replace by standard persist when api includes locationType
    private var persistWithoutOverridingLocation: (MyUser) -> ()


    // MARK: Lifecycle

    init(dataSource: MyUserDataSource, dao: MyUserDAO) {
        self.dataSource = dataSource
        self.dao = dao
        self.persistWithoutOverridingLocation = { myUser in
            var userToSave: MyUser

            if let actualUser = dao.myUser {
                userToSave = myUser.myUserWithNewAuthProvider(actualUser.authProvider)

                if let actualLocation = actualUser.location {
                    userToSave = userToSave.myUserWithNewLocation(actualLocation)
                }

            } else {
                userToSave = myUser
            }
            dao.save(userToSave)
        }
    }


    // MARK: - Public methods

    /**
    Returns the logged user.
    */
    public var myUser: MyUser? {
        return dao.myUser
    }


    /**
    Updates the name of my user.
    - parameter myUserId: My user identifier.
    - parameter name: The name.
    - parameter completion: The completion closure.
    */
    public func updateName(name: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let params: [String: AnyObject] = [LGMyUser.JSONKeys.name: name]
        update(params, completion: completion)
    }

    /**
    Updates the password of my user.
    - parameter myUserId: My user identifier.
    - parameter password: The password.
    - parameter completion: The completion closure.
    */
    public func updatePassword(password: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let params: [String: AnyObject] = [LGMyUser.JSONKeys.password: password]
        update(params, completion: completion)
    }

    /**
    Updates the email of my user.
    - parameter myUserId: My user identifier.
    - parameter email: The email.
    - parameter completion: The completion closure.
    */
    public func updateEmail(email: String, completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        let params: [String: AnyObject] = [LGMyUser.JSONKeys.email: email]
        update(params, completion: completion)
    }

    /**
    Updates the avatar of my user.
    - parameter avatar: The avatar.
    - parameter completion: The completion closure.
    */
    public func updateAvatar(avatar: NSData, progressBlock: ((Int) -> ())?,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
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
    - parameter completion: The completion closure. Will pass api error as the method is internal so that the caller can
                            have the complete error information
    */
    func createWithEmail(email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
        completion: ((Result<MyUser, ApiError>) -> ())?) {
            dataSource.createWithEmail(email, password: password, name: name, newsletter: newsletter,
                location: location, completion: completion)
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

    /**
    Updates the location of my user. If no postal address is passed-by it nullifies it.
    - parameter myUserId: My user identifier.
    - parameter location: The location.
    - parameter postalAddress: The postal address.
    - parameter completion: The completion closure.
    */
    func updateLocation(location: LGLocation, postalAddress: PostalAddress,
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            var params = [String: AnyObject]()
            params[LGMyUser.JSONKeys.latitude] = location.coordinate.latitude
            params[LGMyUser.JSONKeys.longitude] = location.coordinate.longitude
            params[LGMyUser.JSONKeys.zipCode] = postalAddress.zipCode ?? ""
            params[LGMyUser.JSONKeys.address] = postalAddress.address ?? ""
            params[LGMyUser.JSONKeys.city] = postalAddress.city ?? ""
            params[LGMyUser.JSONKeys.countryCode] = postalAddress.countryCode ?? ""

            //TODO: Replace by standard update method when api includes locationType
            updateWithLocation(location, params: params, completion: completion)
    }

    /**
    Saves the given `MyUser`.
    - parameter myUser: My user.
    */
    func save(myUser: MyUser) {
        persistWithoutOverridingLocation(myUser)
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
        var paramsWithId = params
        paramsWithId[LGMyUser.JSONKeys.objectId] = myUserId
        dataSource.update(myUserId, params: paramsWithId) {
            [weak self] (result: Result<MyUser, ApiError>) -> () in
            guard self?.myUser != nil else {
                completion?(Result<MyUser, RepositoryError>(error:
                    .Internal(message: "User logged out while waiting for response")))
                return
            }
            handleApiResult(result, success: self?.persistWithoutOverridingLocation, completion: completion)
        }
    }

    /**
    Updates a `MyUser` with the given parameters but overriding location parameter.
    - parameter location: LGLocation to override on result
    - parameter params: The parameters to be updated.
    - parameter completion: The completion closure.
    */
    private func updateWithLocation(location: LGLocation?, params: [String: AnyObject],
        completion: ((Result<MyUser, RepositoryError>) -> ())?) {
            guard let myUserId = myUser?.objectId else {
                completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Missing MyUser objectId")))
                return
            }
            var paramsWithId = params
            paramsWithId[LGMyUser.JSONKeys.objectId] = myUserId
            dataSource.update(myUserId, params: paramsWithId) { [weak self] (result: Result<MyUser, ApiError>) -> () in
                guard self?.myUser != nil else {
                    completion?(Result<MyUser, RepositoryError>(error:
                        .Internal(message: "User logged out while waiting for response")))
                    return
                }
                if let value = result.value {
                    var userToSave: MyUser
                    if let location = location {
                        userToSave = value.myUserWithNewLocation(location)
                    } else {
                        userToSave = value
                    }

                    // Keep the previously saved auth provider
                    if let actualUser = self?.dao.myUser {
                        userToSave = userToSave.myUserWithNewAuthProvider(actualUser.authProvider)
                    }

                    self?.dao.save(userToSave)

                    completion?(Result<MyUser, RepositoryError>(value: userToSave))
                } else if let apiError = result.error {
                    let error = RepositoryError(apiError: apiError)
                    completion?(Result<MyUser, RepositoryError>(error: error))
                }
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
                    handleApiResult(result, success: self?.persistWithoutOverridingLocation, completion: completion)
            }
    }
}
