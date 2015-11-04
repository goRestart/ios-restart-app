//
//  LGChatsResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGChatsResponse : ChatsResponse {

    public let chats: [Chat]
    
}

extension LGChatsResponse : ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theLGChats : [LGChat] = decode(representation) else {
            return nil
        }
        
        self.chats = theLGChats.map({$0})
    }

}
