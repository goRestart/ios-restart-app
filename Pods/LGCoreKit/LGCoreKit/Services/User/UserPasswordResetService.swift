//
//  UserPasswordResetService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserPasswordResetServiceError: ErrorType {
    case Network
    case InvalidEmail
    case UserNotFound
    case Internal
}

public typealias UserPasswordResetServiceResult = Result<Nil, UserPasswordResetServiceError>
public typealias UserPasswordResetServiceCompletion = UserPasswordResetServiceResult -> Void

public protocol UserPasswordResetService {
    
    /**
        Saves the user.
    
        - parameter email: An email.
        - parameter completion: The completion closure.
    */
    func resetPassword(email: String, completion: UserPasswordResetServiceCompletion?)
}
