//
//  LGChat.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import UIKit

public class LGChat: LGBaseModel, Chat {
    
    // Chat iVars
    public var product: Product?
    public var userFrom: User?
    public var userTo: User?
    public var msgUnreadCount: Int?
    public var messages: [Message]?
    
    // MARK: - Lifecycle
    
    public override init(){
        super.init()
    }
}
