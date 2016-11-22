//
//  UserRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias UsersResult = Result<[User], RepositoryError>
public typealias UsersCompletion = UsersResult -> Void

public typealias UserResult = Result<User, RepositoryError>
public typealias UserCompletion = UserResult -> Void

public typealias UserUserRelationResult = Result<UserUserRelation, RepositoryError>
public typealias UserUserRelationCompletion = UserUserRelationResult -> Void

public typealias UserVoidResult = Result<Void, RepositoryError>
public typealias UserVoidCompletion = UserVoidResult -> Void


public protocol UserRepository {

    /**
    Retrieves the user for the given ID.
    - parameter userId: User identifier.
    - parameter includeAccounts: If the user entity should include accounts.
    - parameter completion: The completion closure.
    */
    func show(userId: String, includeAccounts: Bool, completion: UserCompletion?)

    /**
     Retrieves relation data with other user

     - parameter relatedUserId: Related user Identifier
     - parameter completion:    The Completion closure
     */
    func retrieveUserToUserRelation(relatedUserId: String, completion: UserUserRelationCompletion?)

    /**
     Retrieves the list of all blocked users

     - parameter completion: The completion closure
     */
    func indexBlocked(completion: UsersCompletion?)

    /**
     Blocks a user

     - parameter user:       user to block
     - parameter completion: Completion closure
     */
    func blockUserWithId(userId: String, completion: UserVoidCompletion?)

    /**
     Unblocks a user

     - parameter userId:       user to unblock
     - parameter completion: Completion closure
     */

    func unblockUserWithId(userId: String, completion: UserVoidCompletion?)

    /**
     Unblocks users
     NOTE: if one single unblock fails, the entire response will be a failure

     - parameter userIds:       users to unblock
     - parameter completion: Completion closure
     */

    func unblockUsersWithIds(userIds: [String], completion: UserVoidCompletion?)

    /**
    Reports a 'bad' user

    - parameter reportedUser: User to report
    - parameter params:       Report reason and comment
    - parameter completion:   The completion closure
    */
    func saveReport(reportedUser: User, params: ReportUserParams, completion: UserCompletion?)
    
    func saveReport(reportedUserId: String, params: ReportUserParams, completion: UserVoidCompletion?)
}
