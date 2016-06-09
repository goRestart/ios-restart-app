//
//  MyUserDataSource.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

protocol MyUserDataSource {
    /**
    Retrieves my user with the given my user identifier.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    func show(myUserId: String, completion: ((Result<MyUser, ApiError>) -> ())?)

    /**
    Creates a user with the given email, password and location.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
    - parameter location: The location.
    - parameter completion: The completion closure.
    */
    func createWithEmail(email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
        postalAddress: PostalAddress?, completion: ((Result<MyUser, ApiError>) -> ())?)

    /**
    Updates a my user with the given parameters.
    - parameter myUserId: My user identifier.
    - parameter params: The parameters to be updated.
    - parameter completion: The completion closure.
    */
    func update(myUserId: String, params: [String : AnyObject], completion: ((Result<MyUser, ApiError>) -> ())?)

    /**
    Uploads a new user avatar.
    - parameter avatar: The avatar to be uploaded.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    func uploadAvatar(avatar: NSData, myUserId: String, progressBlock: ((Int) -> ())?,
        completion: ((Result<MyUser, ApiError>) -> ())?)
    
    /**
    Resets the user password with the one given using the token as Authorization header for the API.
    
    - parameter userId:     Identifier of the user resetting the password
    - parameter params:     Params should include the userId ("id") and the new password ("password")
    - parameter token:      Token to be used as Authorization header
    - parameter completion: Completion closure
    */
    func resetPassword(userId: String, params: [String: AnyObject], token: String,
        completion: ((Result<MyUser, ApiError>) -> ())?)


    /**
     Links a new account to with the given user

     - parameter userId:     the user that will link the new account
     - parameter provider:   new account provider
     - parameter completion: completion closure
     */
    func linkAccount(userId: String, provider: LinkAccountProvider, completion: ((Result<Void, ApiError>)->())?)

    /**
     Retrieves counters for the given userid

     - parameter completion: Completion closure
     */
    func retrieveCounters(completion completion: ((Result<UserCounters, ApiError>)->())?)
}
