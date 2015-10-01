//
//  LGChatsUnreadCountResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

@objc public class LGChatsUnreadCountResponse : ChatsUnreadCountResponse, ResponseObjectSerializable {
    
    // Constants
    private static let countJSONKey = "count"
    
    // iVars
    public var count: Int
    
    // MARK: - Lifecycle
    
    public init() {
        count = 0
    }
    
    // MARK: - ResponseObjectSerializable
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let countryInfoDao = RLMCountryInfoDAO()
        let currencyHelper = CurrencyHelper(countryInfoDAO: countryInfoDao)
        
        let json = JSON(representation)
        if let actualCount = json[LGChatsUnreadCountResponse.countJSONKey].int {
            count = actualCount
        }
        else {
            return nil
        }
    }
}
