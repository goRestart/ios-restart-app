//
//  LGUserResponse.swift
//  LGCoreKit
//
//  Created by Dídac on 21/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGUserResponse: UserResponse {
    
    public let user: User
    
}

extension LGUserResponse : ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theUser : LGUser = decode(representation) else {
            return nil
        }
        
        self.user = theUser
    }
}