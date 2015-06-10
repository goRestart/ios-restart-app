//
//  UserLogInFBService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 09/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol UserLogInFBService {
    
    /**
        Logs in / signs up a user via Facebook.
    
        :param: completion The completion closure.
    */
    func logInByFacebooWithCompletion(completion: UserLogInCompletion)
}