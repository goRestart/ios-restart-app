//
//  UserDataSource.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 3/2/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias UserDataSourceCompletion = Result<User, ApiError> -> Void
typealias UserDataSourceEmptyCompletion = Result<Void, ApiError> -> Void

protocol UserDataSource {
    
    /**
    Retrieves a user with the given user identifier.
    - parameter userId: User identifier.
    - parameter completion: The completion closure.
    */
    func show(userId: String, completion: UserDataSourceCompletion?)

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
