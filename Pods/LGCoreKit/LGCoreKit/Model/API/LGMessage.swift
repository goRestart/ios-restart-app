//
//  LGMessage.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 15/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public class LGMessage: LGBaseModel, Message {
    
    // Message iVars
    public var text: String?
    public var type: MessageType
    public var userId: String?
    
    // MARK: - Lifecycle
    
    public override init() {
        self.type = .Text
        super.init()
    }
}