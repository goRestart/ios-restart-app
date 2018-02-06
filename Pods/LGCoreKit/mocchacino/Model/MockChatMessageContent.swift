//
//  MockChatMessageContent.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatMessageContent: ChatMessageContent {
    public var type: ChatMessageType
    public var text: String?
    
    public init(type: ChatMessageType, text: String?) {
        self.type = type
        self.text = text
    }
    
    func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["type"] = type.rawValue
        result["text"] = text
        result["default"] = "Unsupported feature"
        return result
    }
}
