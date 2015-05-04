//
//  SessionService.swift
//  LGCoreKit
//
//  Created by AHL on 28/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public protocol SessionService {
    
    /**
        Retrieves the session token with the given parameters.
    
        :param: params The session token retrieval parameters.
        :param: completion The completion closure.
    */
    func retrieveTokenWithParams(params: RetrieveTokenParams, completion: RetrieveTokenCompletion)
}
