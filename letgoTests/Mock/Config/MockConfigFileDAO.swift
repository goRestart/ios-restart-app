//
//  MockConfigFileDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@testable import LetGo


public class MockConfigDAO : ConfigDAO {
   
    var config : Config?
    var saveCompletion: (() -> Void)?
    
    public func retrieve() -> Config? {
        return config
    }
    
    public func save(config: Config) {
        saveCompletion?()
    }
}
