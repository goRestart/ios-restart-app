//
//  UserLogOutService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol UserLogOutService {
    
    /**
        Logs out a user.
    
        :param: completion The completion closure.
    */
    func logOutWithCompletion(completion: UserLogOutCompletion)
}