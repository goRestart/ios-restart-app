//
//  ChatMessage.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo

public enum ChatMessageType: String {
    case text = "text"
    case offer = "offer"
    case sticker = "sticker"
    case quickAnswer = "quick_answer"
    case expressChat = "express_chat"
    case favoritedProduct  = "favorited_product"
}

public enum ChatMessageWarning: String, Decodable {
    case Spam = "spam"
}

public protocol ChatMessage: BaseModel {
    var talkerId: String { get }
    var text: String { get }
    var sentAt: Date? { get }
    var receivedAt: Date? { get }
    var readAt: Date? { get }
    var type: ChatMessageType { get }
    var warnings: [ChatMessageWarning] { get }

    func markReceived() -> ChatMessage
}

extension ChatMessage {
    public var messageStatus: ChatMessageStatus {
        if let _ = readAt { return .read }
        if let _ = receivedAt { return .received }
        if let _ = sentAt { return .sent }
        return .unknown
    }
}

public enum ChatMessageStatus {
    case sent
    case received
    case read
    case unknown
}
