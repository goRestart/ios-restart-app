//
//  UserSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserSaveServiceError {
    case Network
    case EmailTaken
    case Internal
    case InvalidUsername
}

public typealias UserSaveServiceResult = (Result<User, UserSaveServiceError>) -> Void

public protocol UserSaveService {
    
    /**
        Saves the user.
    
        :param: user The user.
        :param: result The closure containing the result.
    */
    func saveUser(user: User, result: UserSaveServiceResult?)
}
