//
//  MockConfigFileDAO.swift
//  LGCoreKit
//
//  Created by Dídac on 10/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@testable import LetGo


class MockConfigDAO : ConfigDAO {
   
    var config : Config?
    var saveCompletion: (() -> Void)?
    
    func retrieve() -> Config? {
        return config
    }
    
    func save(config: Config) {
        saveCompletion?()
    }
}
