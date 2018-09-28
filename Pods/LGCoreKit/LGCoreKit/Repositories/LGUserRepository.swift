//
//  LGUserRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

final class LGUserRepository: InternalUserRepository {

    var eventsPublishSubject = PublishSubject<UserRepositoryEvent>()
    let dataSource: UserDataSource
    let myUserRepository: MyUserRepository
    let cache: UsersDAO


    // MARK: - Lifecycle

    init(dataSource: UserDataSource, myUserRepository: MyUserRepository, usersDAO: UsersDAO) {
        self.dataSource = dataSource
        self.myUserRepository = myUserRepository
        self.cache = usersDAO
    }

    /**
     Retrieves the user for the given ID.
     - parameter userId: User identifier.
     - parameter completion: The completion closure.
     */
    func show(_ userId: String, completion: UserCompletion?) {
        if let user = cache.retrieve(userId: userId) {
            handleApiResult(Result(value: user), completion: completion)
        } else {
            dataSource.show(userId) { [weak self] result in
                if let user = result.value {
                    self?.cache.save(user: user)
                }
                handleApiResult(result, completion: completion)
            }
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
    func indexBlocked(limit: Int, offset: Int, completion: UsersCompletion?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UsersResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }

        dataSource.indexBlocked(userId, limit: limit, offset: offset) { result in
            handleApiResult(result, completion: completion)
        }
    }

    /**
     Blocks a user

     - parameter user:       user to block
     - parameter completion: Completion closure
     */
    func internalBlockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
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

    func internalUnblockUserWithId(_ userId: String, completion: UserVoidCompletion?) {
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

    func requestVerification(_ requestedUserId: String, completion: RepositoryCompletion<Void>?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserVoidResult(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        let request = LGUserVerificationRequest(requesterUserId: userId, requestedUserId: requestedUserId, status: .requested)
        guard let params = try? request.asDictionary() else {
            completion?(UserVoidResult(error: .internalError(message: "Error generating request params")))
            return
        }
        dataSource.requestVerification(params: params) { result in
            if let error = result.error {
                completion?(RepositoryResult<Void>(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(RepositoryResult<Void>(value: Void()))
            }
        }
    }

    func retriveVerificationRequests(_ requestedUserId: String, completion: RepositoryCompletion<[UserVerificationRequest]>?) {
        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(RepositoryResult<[UserVerificationRequest]>(error: .internalError(message: "Missing objectId in MyUser")))
            return
        }
        dataSource.readVerificationRequests(requestedUserId: requestedUserId, myUserId: userId) { result in
            handleApiResult(result, completion: completion)
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
