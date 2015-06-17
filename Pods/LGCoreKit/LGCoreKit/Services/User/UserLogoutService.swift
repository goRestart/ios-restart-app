//
//  UserLogOutService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum UserLogOutServiceError {
    case General
}

public typealias UserLogOutServiceResult = (Result<Nil, UserLogOutServiceError>) -> Void

public protocol UserLogOutService {
    
    /**
        Logs out a user.
    
        :param: result The closure containing the result.
    */
    func logOutWithResult(result: UserLogOutServiceResult)
}