//
//  MyUserDataSource.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 03/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

typealias MyUserApiResult = Result<MyUser, ApiError>
typealias MyUserApiCompletion = (MyUserApiResult) -> Void

protocol MyUserDataSource {
    /**
    Retrieves my user with the given my user identifier.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    func show(_ myUserId: String, completion: MyUserApiCompletion?)

    /**
    Creates a user with the given email, password and location.
    - parameter email: The email.
    - parameter password: The password.
    - parameter name: The name.
    - parameter newsletter: Whether or not the user accepted newsletter sending. Send to nil if user wasn't asked about it
    - parameter location: The location.
    - parameter postalAddress: The postal address.
    - parameter localeIdentifier: The locale identifier.
    - parameter completion: The completion closure.
    */
    func createWithEmail(_ email: String, password: String, name: String, newsletter: Bool?, location: LGLocation?,
        postalAddress: PostalAddress?, localeIdentifier: String, completion: MyUserApiCompletion?)

    /**
    Updates a my user with the given parameters.
    - parameter myUserId: My user identifier.
    - parameter params: The parameters to be updated.
    - parameter completion: The completion closure.
    */
    func update(_ myUserId: String, params: [String : Any], completion: MyUserApiCompletion?)

    /**
    Uploads a new user avatar.
    - parameter avatar: The avatar to be uploaded.
    - parameter myUserId: My user identifier.
    - parameter completion: The completion closure.
    */
    func uploadAvatar(_ avatar: Data, myUserId: String, progressBlock: ((Int) -> ())?,
        completion: MyUserApiCompletion?)
    
    /**
    Resets the user password with the one given using the token as Authorization header for the API.
    
    - parameter userId:     Identifier of the user resetting the password
    - parameter params:     Params should include the userId ("id") and the new password ("password")
    - parameter token:      Token to be used as Authorization header
    - parameter completion: Completion closure
    */
    func resetPassword(_ userId: String, params: [String: Any], token: String,
        completion: MyUserApiCompletion?)


    /**
     Links a new account to with the given user

     - parameter userId:     the user that will link the new account
     - parameter provider:   new account provider
     - parameter completion: completion closure
     */
    func linkAccount(_ userId: String, provider: LinkAccountProvider, completion: ((Result<Void, ApiError>) -> ())?)
}
