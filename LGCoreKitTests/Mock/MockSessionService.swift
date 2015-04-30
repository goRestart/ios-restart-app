//
//  MockSessionService.swift
//  LGCoreKit
//
//  Created by AHL on 1/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import LGCoreKit
import UIKit

class MockSessionService: SessionService {
    
    var sessionToken: LGSessionToken?
    var error: LGError?
    
    func retrieveTokenWithParams(params: RetrieveTokenParams, completion: RetrieveTokenCompletion) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            completion(token: self.sessionToken, error: self.error)
        }
    }
}
