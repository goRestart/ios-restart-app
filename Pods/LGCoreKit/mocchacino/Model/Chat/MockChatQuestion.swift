//
//  MockChatQuestion.swift
//  LGCoreKit
//
//  Created by Nestor on 02/05/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatQuestion: ChatQuestion {
    public var key: String?
    public var text: String
    
    public init(key: String?,
                text: String) {
        self.key = key
        self.text = text
    }
}
