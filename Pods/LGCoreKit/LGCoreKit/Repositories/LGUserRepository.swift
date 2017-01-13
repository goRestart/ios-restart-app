//
//  LGUserRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

final class LGUserRepository: UserRepository {
    let dataSource: UserDataSource
    let myUserRepository: MyUserRepository


    // MARK: - Lifecycle

    init(dataSource: UserDataSource, myUserRepository: MyUserRepository) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
    }

    /**
     Retrieves the user for the given ID.
     - parameter userId: User identifier.
     - parameter includeAccounts: If the user entity should include accounts.
     - parameter completion: The completion closure.
     */
    func show(_ userId: String, includeAccounts: Bool, completion: UserCompletion?) {
        dataSource.show(userId, includeAccounts: includeAccounts) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    /**
     Retrieves relation data with other user

     - parameter relatedUserId: Related user Identifier
     - parameter completion:    The Completion closure
     */
    func retrieveUserToUserRelation(_ relatedUserId: String, completion: UserUserRelationCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserUserRelationResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.retrieveRelation(userId, relatedUserId: relatedUserId) { result in
            if let error = result.error {
                completion?(UserUserRelationResult(error: RepositoryError(apiError: error)))
            } else if let value = result.value {
                completion?(UserUserRelationResult(value: value))
            }
        }
    }

    /**
     Retrieves the list of all blocked users

     - parameter completion: The completion closure
     */
    func indexBlocked(_ completion: UsersCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UsersResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.indexBlocked(userId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Blocks a user

     - parameter user:       user to block
     - parameter completion: Completion closure
     */
    func blockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(UserVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.blockUser(myUserId, relatedUserId: userId) { result in
            if let error = result.error {
                completion?(UserVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(UserVoidResult(value: Void()))
            }
        }
    }

    /**
     Unblocks a user

     - parameter userId:       user to unblock
     - parameter completion: Completion closure
     */

    func unblockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
        guard let myUserId = myUserRepository.myUser?.objectId else {
            completion?(UserVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.unblockUser(myUserId, relatedUserId: userId) { result in
            if let error = result.error {
                completion?(UserVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(UserVoidResult(value: Void()))
            }
        }
    }

    /**
     Unblocks users
     NOTE: if one single unblock fails, the entire response will be a failure

     - parameter userIds:       users to unblock
     - parameter completion: Completion closure
     */

    func unblockUsersWithIds(_ userIds: [String], completion: UserVoidCompletion?) {

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


    /*


     */

    /**
     Reports a 'bad' user

     - parameter reportedUser: User to report
     - parameter params:       Report reason and comment
     - parameter completion:   The completion closure
     */
    func saveReport(_ reportedUser: User, params: ReportUserParams, completion: UserCompletion?) {

        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        guard let reportedUserId = reportedUser.objectId else {
            completion?(UserResult(error: .internalError(message: "Missing objectId in ReportedUser")))
            return
        }

        dataSource.saveReport(reportedUserId, userId: userId, parameters: params.reportUserApiParams) { result in
            LGUserRepository.handleVoidResultToUser(result, user: reportedUser, completion: completion)
        }
    }

    func saveReport(_ reportedUserId: String, params: ReportUserParams, completion: UserVoidCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.saveReport(reportedUserId, userId: userId, parameters: params.reportUserApiParams) { result in
            if let error = result.error {
                completion?(UserVoidResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(UserVoidResult(value: Void()))
            }
        }
    }


    // MARK: - Private methods

    static func handleVoidResultToUser(_ result: Result<Void, ApiError>, user: User, completion: UserCompletion?) {
        if let error = result.error {
            completion?(UserResult(error: RepositoryError(apiError: error)))
        } else if let _ = result.value {
            completion?(UserResult(value: user))
        }
    }
}
