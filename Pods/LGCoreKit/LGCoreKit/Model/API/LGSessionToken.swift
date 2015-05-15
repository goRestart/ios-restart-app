//
//  LGSessionToken.swift
//  LGCoreKit
//
//  Created by AHL on 29/4/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Timepiece

public class LGSessionToken: SessionToken {
    
    // Constant
    private static let expiralThresholdPercentage: Float = 0.95  // We consider that the token is expired if it passed 95% of the time specified by the API
    
    // > JSON keys
    private static let accessTokenJSONKey = "access_token"
    private static let expiresInJSONKey = "expires_in"
    
    // SessionToken iVars
    public var accessToken: String
    public var expirationDate: NSDate

    // MARK: - Lifecycle
    
    //{
    //    "access_token": "ODNhMDBhN2Y1MWRkYmM1ODQwOWMxNmEyODViYzk2ZGY1NWQ5YWU4NzczMDgyOGFiMjFkMjJkNDdjODJhMjA3Mw",
    //    "expires_in": 3600,
    //    "token_type": "bearer",
    //    "scope": "user"
    //}
    public init(accessToken: String, expirationDate: NSDate) {
        self.accessToken = accessToken
        self.expirationDate = expirationDate
    }
    
    public init?(json: JSON) {
        if let accessToken = json[LGSessionToken.accessTokenJSONKey].string,
           let expiresIn = json[LGSessionToken.expiresInJSONKey].int {
            self.accessToken = accessToken
            
            let now = NSDate()
            let secondsToExpire = Int(Float(expiresIn) * 0.95).seconds
            self.expirationDate = now + secondsToExpire
        }
        else {
            self.accessToken = ""
            self.expirationDate = NSDate()
            return nil
        }
    }
    
    // MARK: - SessionToken
    
    public func isExpired() -> Bool {
        // expiration date is now or after than now
        let now = NSDate()
        return expirationDate.compare(now) != NSComparisonResult.OrderedDescending
    }
}