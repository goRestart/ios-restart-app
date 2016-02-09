//
//  UserRepository.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

public typealias UserResult = Result<User, RepositoryError>
public typealias UserCompletion = UserResult -> Void

public final class UserRepository {
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
    - parameter completion: The completion closure.
    */
    public func show(userId: String, completion: UserCompletion?) {
        dataSource.show(userId) { result in
            handleApiResult(result, success: nil, completion: completion)
        }
    }

    /**
    Reports a 'bad' user

    - parameter reportedUser: User to report
    - parameter params:       Report reason and comment
    - parameter completion:   The completion closure
    */
    public func saveReport(reportedUser: User, params: ReportUserParams, completion: UserCompletion?) {

        guard let userId = myUserRepository.myUser?.objectId else {
            completion?(UserResult(error: .Internal(message: "Missing objectId in MyUser")))
            return
        }

        guard let reportedUserId = reportedUser.objectId else {
            completion?(UserResult(error: .Internal(message: "Missing objectId in ReportedUser")))
            return
        }

        dataSource.saveReport(reportedUserId, userId: userId, parameters: params.reportUserApiParams) { result in
            if let error = result.error {
                completion?(UserResult(error: RepositoryError(apiError: error)))
            } else if let _ = result.value {
                completion?(UserResult(value: reportedUser))
            }
        }
    }
}
