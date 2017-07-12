//
//  UserRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias UsersResult = Result<[User], RepositoryError>
public typealias UsersCompletion = (UsersResult) -> Void

public typealias UserResult = Result<User, RepositoryError>
public typealias UserCompletion = (UserResult) -> Void

public typealias UserUserRelationResult = Result<UserUserRelation, RepositoryError>
public typealias UserUserRelationCompletion = (UserUserRelationResult) -> Void

public typealias UserVoidResult = Result<Void, RepositoryError>
public typealias UserVoidCompletion = (UserVoidResult) -> Void


public enum UserRepositoryEvent {
    case block(userId: String)
    case unblock(userId: String)
}

public protocol UserRepository: class {

    var events: Observable<UserRepositoryEvent> { get }
    
    /**
    Retrieves the user for the given ID.
    - parameter userId: User identifier.
    - parameter completion: The completion closure.
    */
    func show(_ userId: String, completion: UserCompletion?)

    /**
     Retrieves relation data with other user

     - parameter relatedUserId: Related user Identifier
     - parameter completion:    The Completion closure
     */
    func retrieveUserToUserRelation(_ relatedUserId: String, completion: UserUserRelationCompletion?)

    /**
     Retrieves the list of all blocked users

     - parameter completion: The completion closure
     */
    func indexBlocked(_ completion: UsersCompletion?)

    /**
     Blocks a user

     - parameter user:       user to block
     - parameter completion: Completion closure
     */
    func blockUserWithId(_ userId: String, completion: UserVoidCompletion?)

    /**
     Unblocks a user

     - parameter userId:       user to unblock
     - parameter completion: Completion closure
     */

    func unblockUserWithId(_ userId: String, completion: UserVoidCompletion?)

    /**
     Unblocks users
     NOTE: if one single unblock fails, the entire response will be a failure

     - parameter userIds:       users to unblock
     - parameter completion: Completion closure
     */

    func unblockUsersWithIds(_ userIds: [String], completion: UserVoidCompletion?)

    /**
    Reports a 'bad' user

    - parameter reportedUser: User to report
    - parameter params:       Report reason and comment
    - parameter completion:   The completion closure
    */
    func saveReport(_ reportedUser: User, params: ReportUserParams, completion: UserCompletion?)
    
    func saveReport(_ reportedUserId: String, params: ReportUserParams, completion: UserVoidCompletion?)
}

protocol InternalUserRepository: UserRepository {
    var eventsPublishSubject: PublishSubject<UserRepositoryEvent> { get }

    func internalBlockUserWithId(_ userId: String, completion: UserVoidCompletion?)
    func internalUnblockUserWithId(_ userId: String, completion: UserVoidCompletion?)
}

extension InternalUserRepository {
    public var events: Observable<UserRepositoryEvent> {
        return eventsPublishSubject.asObservable()
    }
    
    public func blockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        internalBlockUserWithId(userId) { [weak self] blockResult in
            defer { completion?(blockResult) }
            guard let _ = blockResult.value else { return }
            self?.eventsPublishSubject.onNext(.block(userId: userId))
        }
    }
    
    public func unblockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        internalUnblockUserWithId(userId) { [weak self] unblockResult in
            defer { completion?(unblockResult) }
            guard let _ = unblockResult.value else { return }
            self?.eventsPublishSubject.onNext(.unblock(userId: userId))
        }
    }
    
    /// NOTE: if one single unblock fails, the entire response will be a failure
    public func unblockUsersWithIds(_ userIds: [String], completion: UserVoidCompletion?) {
        guard !userIds.isEmpty else {
            completion?(UserVoidResult(error: .internalError(message: "Missing users to unblock")))
            return
        }
        
        let unblockUsersQueue = DispatchQueue(label: "UnblockUsersQueue", attributes: [])
        unblockUsersQueue.async(execute: {
            for userId in userIds {
                let unblockResult = synchronize({ [weak self] synchCompletion in
                    guard let strongSelf = self else {
                        synchCompletion(UserVoidResult(error: .internalError(message: "self deallocated")))
                        return
                    }
                    strongSelf.unblockUserWithId(userId) { result in
                        synchCompletion(result)
                    }
                    }, timeoutWith: UserVoidResult(error: .internalError(message: "Timeout blocking")))
                
                guard let _ = unblockResult.value else {
                    DispatchQueue.main.async {
                        completion?(unblockResult)
                    }
                    return
                }
            }
            
            DispatchQueue.main.async {
                completion?(UserVoidResult(value: Void()))
            }
        })
    }
}
