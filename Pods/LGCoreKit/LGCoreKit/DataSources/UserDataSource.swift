//
//  UserDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias UsersDataSourceCompletion = Result<[User], ApiError> -> Void

typealias UserDataSourceCompletion = Result<User, ApiError> -> Void
typealias UserDataSourceEmptyCompletion = Result<Void, ApiError> -> Void

typealias UserDataSourceUserRelationResult = Result<UserUserRelation, ApiError>
typealias UserDataSourceUserRelationCompletion = UserDataSourceUserRelationResult -> Void

protocol UserDataSource {
    
    /**
    Retrieves a user with the given user identifier.
    - parameter userId: User identifier.
    - parameter completion: The completion closure.
    */
    func show(userId: String, completion: UserDataSourceCompletion?)

    /**
     Retrieves the relation data between two users

     - parameter userId:        caller User identifier
     - parameter relatedUserId: related User identifier
     - parameter completion:    completion closure
     */
    func retrieveRelation(userId: String, relatedUserId: String, completion: UserDataSourceUserRelationCompletion?)

    /**
     Retrieves the list of users blocked

     - parameter userId:     caller User identifier
     - parameter completion: Completion closure
     */
    func indexBlocked(userId: String, completion: UsersDataSourceCompletion?)

    /**
     Blocks an array of users

     - parameter userId:         caller User identifier
     - parameter relatedUserIds: related Users identifiers
     - parameter completion:     completion closure
     */
    func blockUsers(userId: String, relatedUserIds: [String], completion: UserDataSourceEmptyCompletion?)

    /**
     Unblocks an array of users

     - parameter userId:         caller User identifier
     - parameter relatedUserIds: related Users identifiers
     - parameter completion:     completion closure
     */
    func unblockUsers(userId: String, relatedUserIds: [String], completion: UserDataSourceEmptyCompletion?)

    /**
    Reports a user with the given type and comment

    - parameter reportedUserId: Reported User Identifier
    - parameter userId:         Reporting User Identifier
    - parameter parameters:     Report type and message parameters
    - parameter completion:     The completion closure
    */
    func saveReport(reportedUserId: String, userId: String, parameters: [String: AnyObject],
        completion: UserDataSourceEmptyCompletion?)
}
