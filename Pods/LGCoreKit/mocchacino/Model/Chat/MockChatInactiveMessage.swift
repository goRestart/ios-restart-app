//
//  MockChatInactiveMessage.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatInactiveMessage: ChatInactiveMessage {
    public var objectId: String?
    public var talkerId: String
    public var sentAt: Date?
    public var warnings: [ChatMessageWarning]
    public var content: ChatMessageContent
    
    public init(objectId: String?,
                talkerId: String,
                sentAt: Date?,
                warnings: [ChatMessageWarning],
                content: ChatMessageContent) {
        
        self.objectId = objectId
        self.talkerId = talkerId
        self.sentAt = sentAt
        self.warnings = warnings
        self.content = content
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result["message_id"] = objectId
        result["talker_id"] = talkerId
        result["sent_at"] = Int64((sentAt ?? Date()).timeIntervalSince1970 * 1000.0)
        result["warnings"] = warnings.map { $0.rawValue }
        result["content"] = MockChatMessageContent.makeMock().makeDictionary()
        return result
    }
}
