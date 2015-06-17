//
//  UserPasswordResetService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 17/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserPasswordResetServiceError {
    case Network
    case InvalidEmail
    case UserNotFound
    case Internal
}

public typealias UserPasswordResetServiceResult = (Result<Nil, UserPasswordResetServiceError>) -> Void

public protocol UserPasswordResetService {
    
    /**
    Saves the user.
    
    :param: email An email.
    :param: result The closure containing the result.
    */
    func resetPassword(email: String, result: UserPasswordResetServiceResult)
}
