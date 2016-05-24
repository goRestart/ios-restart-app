//
//  ChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public enum ChatMessageType: String {
    case Text = "text"
    case Offer = "offer"
    case Sticker = "sticker"
}

public protocol ChatMessage: BaseModel {
    var talkerId: String { get }
    var text: String { get }
    var sentAt: NSDate? { get }
    var receivedAt: NSDate? { get }
    var readAt: NSDate? { get }
    var type: ChatMessageType { get }
    
    func markAsSent() -> ChatMessage
    func markAsReceived() -> ChatMessage
    func markAsRead() -> ChatMessage
}

extension ChatMessage {
    public var messageStatus: ChatMessageStatus {
        if let _ = readAt { return .Read }
        if let _ = receivedAt { return .Received }
        if let _ = sentAt { return .Sent }
        return .Unknown
    }
}

public enum ChatMessageStatus {
    case Sent
    case Received
    case Read
    case Unknown
}
