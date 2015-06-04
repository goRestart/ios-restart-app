//
//  UserSaveService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol UserSaveService {
    
    /**
        Saves the user.
    
        :param: user The user.
        :param: completion The completion closure.
    */
    func saveUser(user: User, completion: UserSaveCompletion)
}
