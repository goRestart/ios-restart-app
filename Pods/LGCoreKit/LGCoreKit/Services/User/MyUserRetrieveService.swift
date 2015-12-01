//
//  MyUserRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 19/11/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import Result

public enum MyUserRetrieveServiceError: ErrorType, CustomStringConvertible {
    case Network
    case Internal
    
    public var description: String {
        switch (self) {
        case Network:
            return "Network"
        case Internal:
            return "Internal"
        }
    }
}

public typealias MyUserRetrieveServiceResult = Result<MyUser, MyUserRetrieveServiceError>
public typealias MyUserRetrieveServiceCompletion = MyUserRetrieveServiceResult -> Void

public protocol MyUserRetrieveService {
    
    /**
        Retrieves my user.
    
        - parameter sessionToken: The session token.
        - parameter myUserId: My user id.
        - parameter completion: The completion closure.
    */
    func retrieveMyUserWithSessionToken(sessionToken: String, myUserId: String, completion: MyUserRetrieveServiceCompletion?)
}