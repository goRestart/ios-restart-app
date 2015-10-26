//
//  LGUserResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Alamofire
import SwiftyJSON

public class LGUserResponse: UserResponse, ResponseObjectSerializable {
    
    public var user: User
    
    // MARK: - Lifecycle
    
    public init() {
        user = LGUser()
    }
    
    // MARK: - ResponseObjectSerializable
    
    public required convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.init()
        
        let json = JSON(representation)

        user = LGProductUserParser.userWithJSON(json)
        
    }
}