//
//  UserSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserSaveServiceError: ErrorType {
    case Network
    case EmailTaken
    case Internal
    case InvalidUsername
    case InvalidPassword
    case PasswordMismatch
    case UsernameTaken
}

public typealias UserSaveServiceResult = Result<User, UserSaveServiceError>
public typealias UserSaveServiceCompletion = UserSaveServiceResult -> Void

public protocol UserSaveService {
    
    /**
        Saves the user.
    
        - parameter user: The user.
        - parameter completion: The completion closure.
    */
    func saveUser(user: User, completion: UserSaveServiceCompletion?)
}
