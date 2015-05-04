//
//  MockSessionManager.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit

class MockSessionManager: SessionManager {
    
    let sessionService: MockSessionService
    let userDefaults: NSUserDefaults
    
    init() {
        sessionService = MockSessionService()
        userDefaults = NSUserDefaults(suiteName: "test")!
        super.init(sessionService: sessionService, userDefaults: userDefaults)
    }
    
    func deleteStoredData() {
        for key in userDefaults.dictionaryRepresentation().keys {
            userDefaults.removeObjectForKey(key as! String)
        }
        userDefaults.synchronize()
    }
}