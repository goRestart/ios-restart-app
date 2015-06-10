//
//  UserRetrieveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol UserRetrieveService {
    
    /**
        Retrieves a user.
    
        :param: user The user.
        :param: completion The completion closure.
    */
    func retrieveUser(user: User, completion: UserRetrieveCompletion)
}
