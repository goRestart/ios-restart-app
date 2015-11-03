//
//  LGChatResponse.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo

public struct LGChatResponse : ChatResponse {
    
    public let chat: Chat
    
}

extension LGChatResponse: ResponseObjectSerializable {
    // MARK: - ResponseObjectSerializable
    
    public init?(response: NSHTTPURLResponse, representation: AnyObject) {
        
        guard let theChat : LGChat = decode(representation) else {
            return nil
        }
        
        self.chat = theChat
    }
}
