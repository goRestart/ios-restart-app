//
//  LGChatsUnreadCountResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGChatsUnreadCountResponse : ChatsUnreadCountResponse {
    
    // iVars
    public let count: Int
}

extension LGChatsUnreadCountResponse : ResponseObjectSerializable {
    
    // MARK: - ResponseObjectSerializable
    
    /**
    Representation will come in the following json form:
    
    {
        "count": 30
    }
    */
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        //Direct parsing
        guard let theCount : Int = (JSON.parse(representation) <| "count") else {
            return nil
        }
        
        self.count = theCount
    }
}