//
//  MockConfigRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@testable import LetGo
import Result

class MockConfigRetrieveService : ConfigRetrieveService {

    var mockResult : ConfigRetrieveServiceResult?
    var updateFile : Config!
        
    func retrieveConfigWithCompletion(_ completion: ConfigRetrieveServiceCompletion?) {
        if let actualMockResult = mockResult{
            completion?(actualMockResult)
        }
    }
}
