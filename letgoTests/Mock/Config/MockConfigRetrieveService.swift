//
//  MockConfigRetrieveService.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@testable import LetGo
import Result

public class MockConfigRetrieveService : ConfigRetrieveService {

    var mockResult : ConfigRetrieveServiceResult?
    var updateFile : Config!
        
    public func retrieveConfigWithCompletion(completion: ConfigRetrieveServiceCompletion?) {
        if let actualMockResult = mockResult{
            completion?(actualMockResult)
        }
    }
}
